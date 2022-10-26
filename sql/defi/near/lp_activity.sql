with token_prices as (
	select distinct token_contract, 
      TRUNC(TIMESTAMP,'hour') as timestamp_h, 
      avg(price_usd) as price_usd 
  	from near.core.fact_prices
  	where timestamp >= (current_date - 90)
  	group by 1,2
),
base_liquidity as (
select distinct 
a.block_timestamp,
a.tx_hash, 
b.tx_signer as user_address,
a.method_name,
parse_json(args) as args_parsed
from "NEAR"."CORE"."FACT_ACTIONS_EVENTS_FUNCTION_CALL" a
left join "NEAR"."CORE"."FACT_TRANSACTIONS" b
on a.tx_hash = b.tx_hash
where method_name in ('add_liquidity','remove_liquidity')
  and a.block_timestamp >= (current_date - 90)
limit 100
),
liquidity_total as (
select 
a.block_timestamp,
a.tx_hash,
a.receiver_id,
b.user_address,
b.args_parsed,
b.method_name,
logs,
substring(logs[0],charindex('[',logs[0]),charindex(',',logs[0])-charindex('[',logs[0])) as token0_unclean,
substring(logs[0],charindex(',',logs[0]),charindex(']',logs[0])-charindex(',',logs[0])) as token1_unclean,
substring(token1_unclean,3) as token1_uncleaned,
substring(token0_unclean,3,charindex(' ', token0_unclean)-3) :: number as token0_amt,
substring(token0_unclean,charindex(' ', token0_unclean),len(token0_unclean)-charindex(' ', token0_unclean)) :: string as token0_name,

substring(token1_uncleaned,2,charindex(' ', token1_uncleaned)-2) :: number as token1_amt,
substring(token1_uncleaned,charindex(' ', token1_uncleaned),len(token1_uncleaned)-charindex(' ', token1_uncleaned)) :: string as token1_name
from "NEAR"."CORE"."FACT_RECEIPTS" a
inner join base_liquidity b
on a.tx_hash = b.tx_hash
where (logs::string like '%shares of liquidity removed%' or logs::string like '%Liquidity added%')
and receiver_id not in (select distinct token_contract from "NEAR"."CORE"."DIM_TOKEN_LABELS")
  and a.block_timestamp >= (current_date - 90)
),
add_liquidity_combined as (
select 
distinct 
block_timestamp,
tx_hash,
user_address,
receiver_id as protocol,
token0_amt as token_amount,
trim(token0_name) ::string  as token_name
from liquidity_total
where method_name = 'add_liquidity'
  union
select 
distinct 
  block_timestamp,
tx_hash,
user_address,
receiver_id as protocol,
token1_amt as token_amount,
trim(token1_name) ::string  as token_name
from liquidity_total  
where method_name = 'add_liquidity'
),
add_liquidity_final as (
select 
user_address,
protocol,
token_name as token_contract,
count(distinct tx_hash) as n_deposits,
sum(token_amount/pow(10,b.decimals)) as dep_token_volume,
sum(token_amount/pow(10,b.decimals)*c.price_usd) as dep_usd_volume
from add_liquidity_combined a
left join "NEAR"."CORE"."DIM_TOKEN_LABELS" b
on a.token_name = b.token_contract
left join token_prices c
on a.token_name = c.token_contract and TRUNC(a.block_timestamp,'hour') = c.timestamp_h
group by 1,2,3
),
remove_liquidity_combined as (
select 
distinct 
block_timestamp,
tx_hash,
user_address,
receiver_id as protocol,
token0_amt as token_amount,
trim(token0_name) ::string  as token_name
from liquidity_total
where method_name = 'remove_liquidity'
  union
select 
distinct 
  block_timestamp,
tx_hash,
user_address,
receiver_id as protocol,
token1_amt as token_amount,
trim(token1_name) ::string  as token_name
from liquidity_total  
where method_name = 'remove_liquidity'
),
remove_liquidity_final as (
select 
user_address,
protocol,
token_name as token_contract,
count(distinct tx_hash) as n_withdrawals,
sum(token_amount/pow(10,b.decimals)) as wdraw_token_volume,
sum(token_amount/pow(10,b.decimals)*c.price_usd) as wdraw_usd_volume
from remove_liquidity_combined a
left join "NEAR"."CORE"."DIM_TOKEN_LABELS" b
on a.token_name = b.token_contract
left join token_prices c
on a.token_name = c.token_contract and TRUNC(a.block_timestamp,'hour') = c.timestamp_h
group by 1,2,3
)
select coalesce(a.user_address, b.user_address) as user_address,
coalesce(a.protocol, b.protocol) as protocol,
coalesce(a.token_contract, b.token_contract) as token_contract,
a.n_deposits,
b.n_withdrawals,
a.dep_token_volume,
a.dep_usd_volume,
b.wdraw_token_volume,
b.wdraw_usd_volume
from add_liquidity_final a
full join remove_liquidity_final b
on a.user_address = b.user_address and a.protocol = b.protocol and a.token_contract = b.token_contract
