with token_prices as (
	select 
      TRUNC(TIMESTAMP,'hour') as timestamp_h, 
      avg(price_usd) as price_usd 
  	from near.core.fact_prices
  	where timestamp >= (current_date - 90)
  	AND symbol = 'wNEAR'
  	group by 1
)
select 
  tx_signer as user_address,
  pool_address as protocol,
  'NEAR' as token_contract,
  'NEAR' as token_symbol,
  sum(case when action = 'Stake' then 1 else 0 end) as n_stakes,
  sum(case when action = 'Unstake' then 1 else 0 end) as n_unstakes,
  sum(case when action = 'Stake' then stake_amount else 0 end) / pow(10,24) as stake_token_volume,
  sum(case when action = 'Stake' then stake_amount / pow(10,24) * b.price_usd else 0 end)  as stake_usd_volume,
  sum(case when action = 'Unstake' then stake_amount else 0 end) / pow(10,24) as unstake_token_volume,
  sum(case when action = 'Unstake' then stake_amount / pow(10,24) * b.price_usd else 0 end)  as unstake_usd_volume
from near.core.dim_staking_actions a 
left join token_prices b 
on TRUNC(a.block_timestamp,'hour') = b.timestamp_h
where block_timestamp >= (current_date - 90)
group by 1,2,3,4



