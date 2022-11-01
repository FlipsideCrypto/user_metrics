with near_prices as (
	select 
      TRUNC(TIMESTAMP,'hour') as timestamp_h, 
      avg(price_usd) as price_usd 
  	from near.core.fact_prices
  	where timestamp >= (current_date - 90)
  	AND symbol = 'wNEAR'
  	group by 1
)
select distinct 
tx_receiver,
count(distinct tx_hash) as n_transactions,
sum(deposit/pow(10,24)) as n_tokens_received,
sum(deposit/pow(10,24)*price_usd) as usd_value_received
from "NEAR"."CORE"."FACT_TRANSFERS" a
left join near_prices c 
on TRUNC(a.block_timestamp,'hour') = c.timestamp_h
where tx_receiver like '%.embr.%' and tx_receiver != 'mytestapi.embr.playember_reserve.near'
and block_timestamp >= (current_date - 90)
group by 1
order by 3 desc