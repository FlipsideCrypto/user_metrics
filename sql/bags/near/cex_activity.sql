with near_prices as (
	select 
      TRUNC(TIMESTAMP,'hour') as timestamp_h, 
      avg(price_usd) as price_usd 
  	from near.core.fact_prices
  	where timestamp >= (current_date - 90)
  	AND symbol = 'wNEAR'
  	group by 1
),
deposits as (
  select 
  a.tx_signer as user_address,
  b.project_name as exchange_name,
  count(distinct a.tx_hash) as n_deposits,
  sum(a.deposit / pow(10,24)) as near_tokens_deposited,
  sum(a.deposit / pow(10,24) * c.price_usd) as usd_deposited
  from near.core.fact_transfers a
  inner join (select distinct address, project_name 
  				from crosschain.core.address_labels 
  				where blockchain = 'near' and label_subtype = 'deposit_wallet') b
  on a.tx_receiver = b.address
  left join near_prices c 
  on TRUNC(a.block_timestamp,'hour') = c.timestamp_h
  where 
  block_timestamp >= (current_date - 90)
  group by 1,2
),
withdraws as (
  select tx_receiver as user_address,
  project_name as exchange_name,
  count(distinct tx_hash) as n_withdraws,
  sum(deposit / pow(10,24)) as near_tokens_withdrawn,
  sum(a.deposit / pow(10,24) * c.price_usd) as usd_withdrawn
  from near.core.fact_transfers a
  inner join (select distinct address, project_name 
  				from crosschain.core.address_labels 
  				where blockchain = 'near' and label_subtype = 'hot_wallet') b
  on a.tx_signer = b.address
  left join near_prices c 
  on TRUNC(a.block_timestamp,'hour') = c.timestamp_h
  where 
  block_timestamp >= (current_date - 90)
  group by 1,2
)
select 
coalesce(a.user_address, b.user_address) as user_address,
coalesce(a.exchange_name, b.exchange_name) as exchange_name,
  'NEAR' as token_contract,
  'NEAR' as token_symbol,
a.n_deposits,
b.n_withdraws,
a.near_tokens_deposited as dep_token_volume,
a.usd_deposited as dep_usd_volume,
b.near_tokens_withdrawn as wdraw_token_volume,
b.usd_withdrawn as wdraw_usd_volume
from deposits a
full join withdraws b 
on a.user_address = b.user_address and a.exchange_name = b.exchange_name
