with deposits as (
                         select 
distinct from_address as user_address,
count(distinct tx_hash) as num_deposits,
sum(raw_amount/pow(10,18)*price) as amount_deposited_usd
from bsc.core.fact_token_transfers t
left join bsc.core.fact_hourly_token_prices p 
on t.contract_address = p.token_address and p.hour = date_trunc('hour', t.block_timestamp)
where 
t.tx_hash in (select distinct tx_hash from bsc.core.fact_event_logs
    where contract_address in (select distinct address from bsc.core.dim_labels where label_subtype = 'pool')
                   and event_name = 'Mint' and block_timestamp > current_date - 180)

and origin_from_address = from_address
group by 1
),
withdraws as (
                         select 
distinct from_address as user_address,
count(distinct tx_hash) as num_withdrawals,
sum(raw_amount/pow(10,18)*price) as amount_withdrawn_usd
from bsc.core.fact_token_transfers t
left join bsc.core.fact_hourly_token_prices p 
on t.contract_address = p.token_address and p.hour = date_trunc('hour', t.block_timestamp)
where 
t.tx_hash in (select distinct tx_hash from bsc.core.fact_event_logs
    where contract_address in (select distinct address from bsc.core.dim_labels where label_subtype = 'pool')
                   and event_name = 'Burn' and block_timestamp > current_date - 180)

and origin_from_address = to_address
group by 1
),
lp_combined AS (
      SELECT coalesce(a.user_address,b.user_address) as user_address,
  num_deposits,
  num_withdrawals,
  amount_deposited_usd,
  amount_withdrawn_usd
  FROM deposits a
   FULL OUTER JOIN withdraws b
   on a.user_address = b.user_address
)

SELECT user_address, 
sum(num_deposits) as n_deposits,
sum(num_withdrawals) as n_withdrawals,
sum(amount_deposited_usd) as deposit_volume_usd,
sum(amount_withdrawn_usd) as withdrawal_volume_usd
FROM lp_combined
WHERE user_address IS NOT NULL -- rare fluke in garbage coin with no price.
GROUP BY user_address