with near_prices as (
	select 
      TRUNC(TIMESTAMP,'hour') as timestamp_h, 
      avg(price_usd) as price_usd 
  	from near.core.fact_prices
  	where timestamp >= (current_date - 90)
  	AND symbol = 'wNEAR'
  	group by 1
),
base_txs as (
select distinct tx_hash from near.core.fact_actions_events_function_call where method_name = 'buy'
  and block_timestamp >= (current_date - 90)
),
base_table as (
select 
  distinct
  block_timestamp,
  tx_hash,
regexp_substr(status_value, 'Success') as reg_success,
  replace(value, 'EVENT_JSON:') as logs_cleaned,
  parse_json(logs_cleaned):params:buyer_id::string as buyer_id,
  parse_json(logs_cleaned):params:owner_id::string as owner_id,  
  parse_json(logs_cleaned):params:nft_contract_id::string as nft_contract_id,
  parse_json(logs_cleaned):params:price::number / pow(10,24) as price
FROM near.core.fact_receipts,
  table(flatten(input =>logs))
WHERE reg_success IS NOT NULL
and tx_hash in (select distinct tx_hash from base_txs)
and receiver_id = 'marketplace.paras.near'
and buyer_id is not null
and owner_id is not null
and parse_json(logs_cleaned):type != 'resolve_purchase_fail'
and block_timestamp >= (current_date - 90)
),
buys as (
select distinct 
  buyer_id as trader,
  nft_contract_id,
  count(distinct tx_hash) as n_buys,
  sum(price) as near_amt_buys,
  sum(price * price_usd) as usd_amt_buys
  from base_table a
  left join near_prices b
  on TRUNC(a.block_timestamp,'hour') = b.timestamp_h
  group by 1,2
),
sells as (
select distinct 
  owner_id as trader,
  nft_contract_id,
  count(distinct tx_hash) as n_sells,
  sum(price) as near_amt_sells,
  sum(price * price_usd) as usd_amt_sells
  from base_table a
  left join near_prices b
  on TRUNC(a.block_timestamp,'hour') = b.timestamp_h
  group by 1,2
)
select coalesce(a.trader, b.trader) as user_address,
'marketplace.paras.near' as marketplace,
coalesce(a.nft_contract_id, b.nft_contract_id) as nf_token_contract,
replace(coalesce(a.nft_contract_id, b.nft_contract_id),'.near','') as nft_project,
'NEAR' as token_contract,
'NEAR' as token_symbol,
a.n_buys,
a.near_amt_buys as buy_token_volume,
a.usd_amt_buys as buy_usd_volume,
b.n_sells,
b.near_amt_sells as sell_token_volume,
b.usd_amt_sells as sell_usd_volume
from buys a
full join sells b
on a.trader = b.trader and a.nft_contract_id = b.nft_contract_id

