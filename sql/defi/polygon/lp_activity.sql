 -- this will cover swaps from
-- uniswapv3; curve; balancerv2; sushi
with mb as (
 select min(block_number) as minblock
   from polygon.core.fact_blocks
   where block_timestamp > current_date - 3 
),
unipools as (
  with raw as (
SELECT
    livequery.live.udf_api(
        'POST',
        'https://api.thegraph.com/subgraphs/name/messari/uniswap-v3-polygon',
        {'Content-Type': 'application/json'},
        {'query':'{\n  liquidityPools(first: 200, orderBy: totalValueLockedUSD, orderDirection: desc) {
          \n    id\n    totalLiquidity\n    name\n  
            inputTokens { \n id \n symbol \n }}\n}',
        'variables':{}
        },
        ''
    ) as rawoutput
)
select
value:id as pool_address,
value:name as pool_name,
value:inputTokens[0]:id as token0_address,
value:inputTokens[1]:id as token1_address,
value:inputTokens[0]:symbol as token0_symbol,
value:inputTokens[1]:symbol as token1_symbol
from raw, lateral flatten(input => parse_json(rawoutput:data:data:liquidityPools))
),

curvepools as (
  with raw as (
SELECT
    livequery.live.udf_api(
        'POST',
        'https://api.thegraph.com/subgraphs/name/messari/curve-finance-polygon',
        {'Content-Type': 'application/json'},
        {'query':'{\n  liquidityPools(first: 30, orderBy: totalValueLockedUSD, orderDirection: desc) {
          \n    id\n    totalValueLockedUSD\n    name\n  
            inputTokens { \n id \n symbol \n }}\n}',
        'variables':{}
        },
        ''
    ) as rawoutput
)
select
value:id as pool_address,
value:name as pool_name,
value:inputTokens[0]:id as token0_address,
value:inputTokens[1]:id as token1_address,
value:inputTokens[2]:id as token2_address,
value:inputTokens[0]:symbol as token0_symbol,
value:inputTokens[1]:symbol as token1_symbol,
value:inputTokens[2]:symbol as token2_symbol
from raw, lateral flatten(input => parse_json(rawoutput:data:data:liquidityPools))
),

quickswappools as (
  with raw as (
SELECT
    livequery.live.udf_api(
        'POST',
        'https://api.thegraph.com/subgraphs/name/sameepsi/quickswap-v3',
        {'Content-Type': 'application/json'},
        {'query':'{
  pools(first: 100 orderBy: volumeUSD orderDirection: desc){
    id
    token0 {
      id
      symbol
    }
    token1 {
      id
      symbol
    }
    totalValueLockedUSD
  }
}',
        'variables':{}
        },
        ''
    ) as rawoutput
)
select
value:id as pool_address,
concat('quickswap ',value:token0:symbol,'-',value:token1:symbol) as pool_name,
value:token0:id as token0_address,
value:token1:id as token1_address,
value:token0:symbol as token0_symbol,
value:token1:symbol as token1_symbol
from raw, lateral flatten(input => parse_json(rawoutput:data:data:pools))
),

-- swap txns
uniswaps as (
  select 
  tx_hash,
  case when substr(decoded_log:amount0,0,3)::integer > 0 then decoded_log:amount0::float
       else decoded_log:amount1::float end as amount_in,
  case when substr(decoded_log:amount1,0,3)::integer < 0 then decoded_log:amount1::float * -1
       else decoded_log:amount0::float * -1 end as amount_out, 
  'uniswap' as platform 
from polygon.core.ez_decoded_event_logs logs
    where logs.topics[0] = '0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67'
    and contract_address in (select lower(pool_address) from unipools)
    and logs.block_number > (select minblock from mb)
),
curveswaps as (
    select tx_hash,
    decoded_log:tokens_sold::float as amount_in,
    decoded_log:tokens_bought::float as amount_out,
     'curve' as platform from polygon.core.ez_decoded_event_logs
  where topics[0] in (
   '0x8b3e96f2b889fa771c53c981b40daf005f63f637f1869f707052d15a3dd97140', -- exchange
   '0xb2e76ae99761dc136e598d4a629bb347eccb9532a5f8bbd72e18467c3c34cc98', -- exchange
   '0xd013ca23e77a65003c2c659c5442c00c805371b7fc1ebd4c206c41d1536bd90b' -- exchange underlying
  )
  and block_number > (select minblock from mb)
  and contract_address in (select lower(pool_address) from curvepools)
),
balancerswaps as (
    select 
    tx_hash, 
    decoded_log:amountIn::float as amount_in,
    decoded_log:amountOut::float as amount_out,
    'balancer' as platform 
from polygon.core.ez_decoded_event_logs
  where topics[0] = '0x2170c741c41531aec20e7c107c24eecfdd15e69c9bb0a8dd37b1840b9e0b207b'
  and block_number > (select minblock from mb)
  and contract_address = lower('0xba12222222228d8ba445958a75a0704d566bf2c8')
),
quickswaps as (
   SELECT 
   tx_hash,
   case when decoded_log:amount0::float > 0 then decoded_log:amount0::float 
        else decoded_log:amount1::float end as amount_in,
   case when decoded_log:amount1::float < 0 then decoded_log:amount1::float * -1
        else decoded_log:amount0::float * -1 end as amount_out,
   'quickswap' as platform
 from polygon.core.ez_decoded_event_logs
 where block_number > (select minblock from mb)
 and event_name = 'Swap'
 and contract_address in (select pool_address from quickswappools)
),

allswaps as (
  select * from uniswaps
UNION
select * from curveswaps
UNION
select * from balancerswaps
UNION
select * from quickswaps
),

allpools as ( 
select pool_address::VARCHAR as pool_address, 
pool_name::VARCHAR as pool_name, 'uniswap' as platform from unipools
UNION
select pool_address::VARCHAR as pool_address,
 pool_name::VARCHAR as pool_name,
 'quickswap' as platform from quickswappools
UNION
select pool_address::VARCHAR as pool_address,
 pool_name::VARCHAR as pool_name, 
'curve' as platform from curvepools
UNION
select lower('0xba12222222228d8ba445958a75a0704d566bf2c8')::VARCHAR as pool_address,
'balancer router'::VARCHAR as pool_name, 'balancer' as platform from dual
),

prices as (
select * from crosschain.core.ez_hourly_prices ezp 
where ezp.blockchain = 'polygon'
and ezp.hour >= '{{start_date}}'
and ezp.hour  <= '{{end_date}}'
and ezp.decimals IS NOT NULL
),

token_deposits AS ( 
SELECT ORIGIN_FROM_ADDRESS as USER_ADDRESS,
 TO_ADDRESS as pool_address, 
CONTRACT_ADDRESS, prices.symbol, 
sum(RAW_AMOUNT / pow(10,prices.decimals)) as amount_deposited_lp, 
sum((RAW_AMOUNT / pow(10,prices.decimals)) * price) as amount_deposited_usd,
count(*) as num_deposits  
FROM polygon.core.fact_token_transfers xfers
JOIN prices
ON date_trunc('hour',xfers.block_timestamp) = prices.hour and 
prices.token_address = xfers.contract_address
where BLOCK_TIMESTAMP >= '{{start_date}}'
 AND block_timestamp <= '{{end_date}}'
 AND TO_ADDRESS IN (SELECT POOL_ADDRESS FROM allpools) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM allswaps)
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, prices.symbol, TO_ADDRESS
), 

token_withdraws AS (
SELECT TO_ADDRESS as USER_ADDRESS, FROM_ADDRESS as pool_address, CONTRACT_ADDRESS, 
prices.symbol, 
sum(RAW_AMOUNT / pow(10,prices.decimals)) as amount_withdrawn_lp, 
sum((RAW_AMOUNT / pow(10,prices.decimals)) * price) as amount_withdrawn_usd,
count(*) as num_withdrawals
FROM polygon.core.fact_token_transfers xfers
JOIN prices
ON date_trunc('hour',xfers.block_timestamp) = prices.hour and 
prices.token_address = xfers.contract_address
where BLOCK_TIMESTAMP >= '{{start_date}}'
      AND xfers.block_timestamp <= '{{end_date}}'
AND FROM_ADDRESS IN (SELECT POOL_ADDRESS FROM allpools) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM allswaps)
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, prices.symbol, FROM_ADDRESS 
),

matic_deposits as (
SELECT ORIGIN_FROM_ADDRESS as USER_ADDRESS, MATIC_TO_ADDRESS as pool_address, NULL as CONTRACT_ADDRESS,
 'MATIC' as symbol, 
sum(AMOUNT) as amount_deposited_lp, 
sum(AMOUNT_USD) as amount_deposited_usd,
count(*) as num_deposits  
FROM polygon.core.ez_matic_transfers xfers
where BLOCK_TIMESTAMP >= '{{start_date}}'
      AND block_timestamp <= '{{end_date}}'
 AND MATIC_TO_ADDRESS IN (SELECT POOL_ADDRESS FROM allpools) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM allswaps)
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, symbol, pool_address
),

matic_withdraws as (
SELECT MATIC_TO_ADDRESS as USER_ADDRESS, MATIC_FROM_ADDRESS as pool_address, NULL as CONTRACT_ADDRESS,
 'MATIC' as symbol, 
sum(AMOUNT) as amount_withdrawn_lp, 
sum(AMOUNT_USD) as amount_withdrawn_usd,
count(*) as num_withdrawals  
FROM polygon.core.ez_matic_transfers xfers
WHERE BLOCK_TIMESTAMP >= '{{start_date}}'
      AND block_timestamp <= '{{end_date}}'
 AND MATIC_FROM_ADDRESS IN (SELECT POOL_ADDRESS FROM allpools) AND 
  -- NOTE: This extreme removal may impact multicalls that transfer & trade in same tx.
  -- This may also miss deposit aggregation, where you transfer to a router that then transfers
  -- to LPs, e.g., Gamma.xyz Uniswap v3 Vaults.
TX_HASH NOT IN (SELECT TX_HASH FROM allswaps)
GROUP BY USER_ADDRESS, CONTRACT_ADDRESS, symbol, pool_address
),

lp_combined AS (
   SELECT * FROM token_deposits NATURAL FULL OUTER JOIN token_withdraws
   UNION
   SELECT * FROM matic_deposits NATURAL FULL OUTER JOIN matic_withdraws
)

SELECT user_address, 
distinct(platform) as protocol, 
sum(num_deposits) as n_deposits,
sum(num_withdrawals) as n_withdrawals,
sum(amount_deposited_usd) as deposit_volume_usd,
sum(amount_withdrawn_usd) as withdrawal_volume_usd
FROM lp_combined lpc
JOIN allpools spd 
ON lpc.pool_address = spd.pool_address
WHERE user_address IS NOT NULL -- rare fluke in garbage coin with no price.
AND user_address NOT IN (select address from polygon.core.dim_labels)
GROUP BY user_address,protocol;