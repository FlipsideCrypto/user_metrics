  WITH optimism_prices AS (
SELECT DATE_TRUNC('week', hour) as day, token_address, symbol, 
AVG(price) / AVG(POWER(10, decimals)) as price_multiplier 
FROM optimism.core.fact_hourly_token_prices
GROUP BY day, token_address, symbol
),

eth_price AS (
SELECT DATE_TRUNC('week', hour) as day, AVG(price) as price_usd 
FROM ethereum.core.fact_hourly_token_prices
WHERE token_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
GROUP BY day 
),

out_optimism_rawa AS (
SELECT DISTINCT DATE_TRUNC('week', a.block_timestamp) as day, a.contract_address, a.origin_from_address as user_address, 
COUNT(*) as num_transactions_out, SUM(raw_amount) as vol, SUM(tx_fee) as sum_fee_eth_out
FROM optimism.core.fact_token_transfers a LEFT JOIN optimism.core.fact_transactions b 
ON a.tx_hash = b.tx_hash
WHERE a.to_address = '0xa420b2d1c0841415a695b81e5b867bcd07dff8c9'
AND a.origin_function_signature = '0x49228978'
AND a.contract_address IS NOT NULL 
AND raw_amount IS NOT NULL 
  and a.block_timestamp >= current_date - 180
  and b.block_timestamp >= current_date - 180
GROUP BY day, a.contract_address, a.origin_from_address
),

out_optimisma AS (
SELECT a.day, symbol, user_address, num_transactions_out, vol * price_multiplier as vol_usd_out, 
sum_fee_eth_out, sum_fee_eth_out * price_usd as eth_fees_usd_out
FROM out_optimism_rawa a LEFT JOIN optimism_prices b 
ON a.day = b.day AND a.contract_address = b.token_address
LEFT JOIN eth_price c
ON a.day = c.day 
),

in_optimism_rawa AS (
SELECT DATE_TRUNC('week', a.block_timestamp) as day, a.contract_address, a.origin_from_address as user_address, 
COUNT(*) as num_transactions_in, SUM(raw_amount) as vol, SUM(tx_fee) as sum_fee_eth_in
FROM optimism.core.fact_token_transfers a LEFT JOIN optimism.core.fact_transactions b 
ON a.tx_hash = b.tx_hash
WHERE a.to_address = '0xa420b2d1c0841415a695b81e5b867bcd07dff8c9'
AND a.origin_function_signature = '0xac9650d8'
AND a.contract_address IS NOT NULL 
AND raw_amount IS NOT NULL 
  and a.block_timestamp >= current_date - 180
  and b.block_timestamp >= current_date - 180
GROUP BY day, a.contract_address, a.origin_from_address
),

in_optimisma AS (
SELECT a.day, symbol, user_address, num_transactions_in, vol * price_multiplier as vol_usd_in, 
sum_fee_eth_in, sum_fee_eth_in * price_usd as eth_fees_usd_in
FROM in_optimism_rawa a LEFT JOIN optimism_prices b 
ON a.day = b.day AND a.contract_address = b.token_address
LEFT JOIN eth_price c
ON a.day = c.day 
),

selecta AS (
SELECT 
    COALESCE(a.day, b.day) as day, 
    'Across' as bridge, 
    COALESCE(a.user_address, b.user_address) as user_address, 
    COALESCE(num_transactions_in, 0) + COALESCE(num_transactions_out, 0) as num_transactions, 
    COALESCE(vol_usd_in, 0) + COALESCE(vol_usd_out, 0) as total_vol_usd, 
    COALESCE(vol_usd_in, 0) - COALESCE(vol_usd_out, 0) as net_vol_in_usd, 
    COALESCE(vol_usd_in, 0) as vol_usd_in, 
    COALESCE(vol_usd_out, 0) as vol_usd_out, 
    COALESCE(eth_fees_usd_out, 0) + COALESCE(eth_fees_usd_in, 0) as eth_fees 
FROM 
    in_optimisma a 
    FULL JOIN out_optimisma b 
        ON a.day = b.day and a.user_address = b.user_address
),

optimism_pricess AS (
SELECT DATE_TRUNC('DAY', hour) as day, token_address, symbol, 
AVG(price) / AVG(POWER(10, decimals)) as price_multiplier 
FROM optimism.core.fact_hourly_token_prices
GROUP BY day, token_address, symbol
),

out_optimism_raws AS (
SELECT DATE_TRUNC('week', a.block_timestamp) as day, a.contract_address, a.origin_from_address as user_address,
COUNT(*) as num_transactions_out, SUM(raw_amount) as vol, SUM(tx_fee) as sum_fee_eth_out
FROM optimism.core.fact_token_transfers a LEFT JOIN optimism.core.fact_transactions b 
ON a.tx_hash = b.tx_hash
WHERE (a.from_address = LOWER('0x470f9522ff620eE45DF86C58E54E6A645fE3b4A7')
AND a.to_address = LOWER('0xaf41a65f786339e7911f4acdad6bd49426f2dc6b'))
OR a.to_address = LOWER('0x470f9522ff620eE45DF86C58E54E6A645fE3b4A7')
  and a.block_timestamp >= current_date - 180
  and b.block_timestamp >= current_date - 180
GROUP BY day, a.contract_address, a.origin_from_address
),

out_optimisms AS (
SELECT a.day, symbol, user_address, num_transactions_out, vol * price_multiplier as vol_usd_out, 
sum_fee_eth_out * price_usd as eth_fees_usd_out
FROM out_optimism_raws a LEFT JOIN optimism_pricess b 
ON a.day = b.day AND a.contract_address = b.token_address
LEFT JOIN eth_price c ON a.day = c.day 
WHERE symbol IS NOT NULL 
),

in_optimism_raws AS (
SELECT DATE_TRUNC('week', a.block_timestamp) as day, a.contract_address, a.to_address as user_address, 
COUNT(*) as num_transactions_in, SUM(raw_amount) as vol, SUM(tx_fee) as sum_fee_eth_in
FROM optimism.core.fact_token_transfers a LEFT JOIN optimism.core.fact_transactions b
ON a.tx_hash = b.tx_hash
WHERE a.from_address = '0xaf41a65f786339e7911f4acdad6bd49426f2dc6b'
  and a.block_timestamp >= current_date - 180
  and b.block_timestamp >= current_date - 180
GROUP BY day, a.contract_address, a.to_address
),

in_optimisms AS (
SELECT a.day, symbol, user_address, num_transactions_in, vol * price_multiplier as vol_usd_in, 
sum_fee_eth_in * price_usd as eth_fees_usd_in
FROM in_optimism_raws a LEFT JOIN optimism_prices b 
ON a.day = b.day AND a.contract_address = b.token_address
LEFT JOIN eth_price c ON a.day = c.day 
WHERE symbol IS NOT NULL 
),

selects AS (
   SELECT COALESCE(a.day, b.day) as day, 
    'Synapse' as bridge, 
    COALESCE(a.user_address, b.user_address) as user_address, 
    COALESCE(num_transactions_in, 0) + COALESCE(num_transactions_out, 0) as num_transactions, 
    COALESCE(vol_usd_in, 0) + COALESCE(vol_usd_out, 0) as total_vol_usd, 
    COALESCE(vol_usd_in, 0) - COALESCE(vol_usd_out, 0) as net_vol_in_usd, 
    COALESCE(vol_usd_in, 0) as vol_usd_in, 
    COALESCE(vol_usd_out, 0) as vol_usd_out, 
    COALESCE(eth_fees_usd_out, 0) + COALESCE(eth_fees_usd_in, 0) as eth_fees 
FROM out_optimisms a FULL JOIN in_optimisms b
ON a.day = b.day and a.user_address = b.user_address
),
synapse_across as (

SELECT *
FROM selecta

UNION

SELECT *
FROM selects

),
hop_bridge as ( select tx_hash
from ethereum.core.fact_event_logs
where event_inputs:chainId = '10' and contract_address in (lower('0xb8901acb165ed027e32754e0ffe830802919727f')
, lower('0x3666f603cc164936c1b87e207f36beba4ac5f18a'), lower('0x3e4a3a4796d16c0cd582c382691998f7c06420b6'),
lower('0x3d4cc8a61c7528fd86c55cfe061a78dcba48edd1'), lower('0x22b1cbb8d98a01a3b71d034bb899775a76eb1cc2')))
,
hop_amount as ( select block_timestamp, origin_from_address, tx_hash, amount_usd
from ethereum.core.ez_eth_transfers
where tx_hash in ( select tx_hash from hop_bridge)
UNION
select block_timestamp, origin_from_address, tx_hash, amount_usd
from ethereum.core.ez_token_transfers
where tx_hash in ( select tx_hash from hop_bridge))
,
native_bridge as ( select block_timestamp, origin_from_address, tx_hash, amount_usd
from ethereum.core.ez_eth_transfers
where eth_to_address = lower('0x99c9fc46f92e8a1c0dec1b1747d010903e884be1')
UNION
select block_timestamp, origin_from_address, tx_hash, amount_usd
from ethereum.core.ez_token_transfers
where to_address = '0x99c9fc46f92e8a1c0dec1b1747d010903e884be1')
,
final as 
( select 'hop' as bridge, *
  from hop_amount
  UNION
  select 'canonical' as bridge, *
  from native_bridge
),
hop_op_bridge_in as (
 select DISTINCT origin_from_address as USER_ADDRESS, 
 bridge,
  count(DISTINCT(tx_hash)) as NUM_TRANSACTIONS,
sum(amount_usd) as vol_usd_in
from final
where block_timestamp::date >= CURRENT_DATE - 180
group by 1,2
),
base_op_bout as (
select distinct 
  block_timestamp,
  tx_hash, 
  from_address as user_address,
  case when contract_address = '0xdeaddeaddeaddeaddeaddeaddeaddeaddead0000' then '0x4200000000000000000000000000000000000006' else contract_address end as token_address,
  raw_amount
  from optimism.core.fact_token_transfers
  where origin_to_address = '0x4200000000000000000000000000000000000010' 
  and block_timestamp::date >= CURRENT_DATE - 180
),
op_bout_p as (
  select distinct a.user_address,
  'canonical' as bridge,
  count(distinct a.tx_hash) as num_transactions,
  sum((a.raw_amount/pow(10,p.decimals)) * p.price) as vol_usd_out
from base_op_bout a
left join optimism.core.fact_hourly_token_prices p 
  on date_trunc('hour', a.block_timestamp) = p.hour and a.token_address = p.token_address 
group by 1,2
),
base_final_bridges as (
select user_address, bridge, num_transactions, vol_usd_in, vol_usd_out
from 
synapse_across
union
select user_address, bridge, num_transactions, vol_usd_in, 0 as vol_usd_out
from 
hop_op_bridge_in
union 
select user_address, bridge, num_transactions, 0 as vol_usd_in, vol_usd_out
from op_bout_p
)
select
distinct user_address,
bridge as bridge_name, 
sum(num_transactions) as num_bridges,
sum(vol_usd_in) as vol_usd_bridge_in,
sum(vol_usd_out) as vol_usd_bridge_out
from base_final_bridges
group by 1,2