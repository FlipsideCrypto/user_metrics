select 
distinct from_address as user_address,
sum(case when block_timestamp >= DATEADD('day', -30, CURRENT_DATE()) then 1 else 0 end) as n_swaps_30d,
sum(case when block_timestamp >= DATEADD('day', -30, CURRENT_DATE()) then raw_amount/pow(10,18)*price else 0 end) as swap_amount_usd_30d,
sum(case when block_timestamp >= DATEADD('day', -60, CURRENT_DATE()) then 1 else 0 end) as n_swaps_60d,
sum(case when block_timestamp >= DATEADD('day', -60, CURRENT_DATE()) then raw_amount/pow(10,18)*price else 0 end) as swap_amount_usd_60d,
sum(case when block_timestamp >= DATEADD('day', -90, CURRENT_DATE()) then 1 else 0 end) as n_swaps_90d,
sum(case when block_timestamp >= DATEADD('day', -90, CURRENT_DATE()) then raw_amount/pow(10,18)*price else 0 end) as swap_amount_usd_90d,
sum(case when block_timestamp >= DATEADD('day', -180, CURRENT_DATE()) then 1 else 0 end) as n_swaps_180d,
sum(case when block_timestamp >= DATEADD('day', -180, CURRENT_DATE()) then raw_amount/pow(10,18)*price else 0 end) as swap_amount_usd_180d
from bsc.core.fact_token_transfers t
left join bsc.core.fact_hourly_token_prices p 
on t.contract_address = p.token_address and p.hour = date_trunc('hour', t.block_timestamp)
where t.tx_hash in (select distinct tx_hash from bsc.core.fact_event_logs
    where contract_address in (select distinct address from bsc.core.dim_labels where label_subtype = 'pool')
                   and event_name = 'Swap' and block_timestamp > current_date - 180)
    and from_address in ( select distinct origin_from_address from bsc.core.fact_event_logs
    where contract_address in (select distinct address from bsc.core.dim_labels where label_subtype = 'pool' )
                   and event_name = 'Swap' and block_timestamp > current_date - 180)
group by 1