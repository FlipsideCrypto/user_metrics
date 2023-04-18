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

--tie to transfers
tokenswapsin as (
select distinct
xfers.block_timestamp,
xfers.tx_hash,
xfers.contract_address as token_address_in,
xfers.raw_amount as raw_amount_in,
abs(raw_amount_in) / pow(10,tp.decimals) as amount_in_adj,
tp.price,
tp.symbol,
amount_in_adj * tp.price as amount_in_usd,
xfers.origin_from_address as user_address,
--xfers.from_address as user_address,
xfers.to_address,
allswaps.platform
from polygon.core.fact_token_transfers xfers
join allswaps on allswaps.tx_hash = xfers.tx_hash
AND allswaps.amount_in = xfers.raw_amount
join crosschain.core.ez_hourly_prices tp on tp.token_address = xfers.contract_address
AND tp.hour = date_trunc('hour',xfers.block_timestamp)
where block_number > (select minblock from mb)
AND tp.hour > current_date - 3
AND tp.blockchain = 'polygon'
),

tokenswapsout as (
select distinct
xfers.block_timestamp,
xfers.tx_hash,
xfers.contract_address as token_address_out,
xfers.raw_amount as raw_amount_out,
abs(raw_amount_out) / pow(10,tp.decimals) as amount_out_adj,
tp.price,
tp.symbol,
amount_out_adj * tp.price as amount_out_usd,
xfers.origin_from_address,
xfers.from_address,
xfers.to_address as user_address,
allswaps.platform
from polygon.core.fact_token_transfers xfers
join allswaps on allswaps.tx_hash = xfers.tx_hash
AND allswaps.amount_out = xfers.raw_amount
join crosschain.core.ez_hourly_prices tp on tp.token_address = xfers.contract_address
AND tp.hour = date_trunc('hour',xfers.block_timestamp)
where block_number > (select minblock from mb)
AND tp.hour > current_date - 3
AND tp.blockchain = 'polygon'
),
final_base as (
select 
user_address,
platform as protocol,
token_address_in as token_contract,
symbol as token_symbol,
count(*) as n_buys,
0 as n_sells,
sum(amount_in_adj) as buy_token_volume,
sum(amount_in_usd) as buy_usd_volumme
0 as sell_token_volume,
0 as sell_usd_volume
from
tokenswapsin
union
select 
user_address,
platform as protocol,
token_address_out as token_contract,
symbol as token_symbol,
0 as n_buys,
count(*) as n_sells,
0 as buy_token_volume,
0 as buy_usd_volumme
sum(amount_out_adj) as sell_token_volume,
sum(amount_out_usd) as sell_usd_volume
from
tokenswapsin
)
select
distinct
user_address,
protocol,
token_contract,
token_symbol,
sum(n_buys) as n_buys,
sum(n_sells) as n_sells,
sum(buy_token_volume) as buy_token_volume,
sum(buy_usd_volumme) as buy_usd_volumme
sum(sell_token_volume) as sell_token_volume,
sum(sell_usd_volume) as sell_usd_volume
from final_base
group by 1,2,3,4