-- user_address | bridge_name | token_contract | token_symbol | n_in | n_out | in_token_volume | in_usd_volume | out_token_volume | out_usd_volume
-- PLACE Bridges USING PLACEHOLDER BELOW 

-- looking at defillama's rankings as of april 2023
-- top 2 bridges are multichain and stargate
-- next are celer hop synapse
-- the canonical bridge should also be covered if possible

with bridges as (
select distinct address, address_name, project_name from polygon.core.dim_labels where project_name = 'multichain' and address_name like '%any%'
union
select lower('0x1205f31718499dBf1fCa446663B532Ef87481fe1') as address, 'USDC' as address_name, 'stargate' as project_name union
  select lower('0x29e38769f23701A2e4A8Ef0492e19dA4604Be62c') as address, 'USDT' as address_name, 'stargate' as project_name union
  select lower('0x1c272232Df0bb6225dA87f4dEcD9d37c32f63Eea') as address, 'DAI' as address_name, 'stargate' as project_name union
  select lower('0x8736f92646B2542B3e5F3c63590cA7Fe313e283B') as address, 'MAI' as address_name, 'stargate' as project_name 
union
  select lower('0x8f5bbb2bb8c2ee94639e55d5f41de9b4839c1280') as address, 'synapse' as address_name, 'synapse' as project_name union
  select lower('0x1c6ae197ff4bf7ba96c66c5fd64cb22450af9cc8') as address, 'synapse zap' as address_name, 'synapse' as project_name
union
  select lower('0xc315239cfb05f1e130e7e28e603cea4c014c57f0') as address, 'ETH' as address_name, 'hop' as project_name union
  select lower('0x25d8039bb044dc227f741a9e381ca4ceae2e6ae8') as address, 'USDC' as address_name, 'hop' as project_name union
  select lower('0xa6a688F107851131F0E1dce493EbBebFAf99203e') as address, 'USDC' as address_name, 'hop' as project_name union
  select lower('0xa6a688F107851131F0E1dce493EbBebFAf99203e') as address, 'USDT' as address_name, 'hop' as project_name union
  select lower('0xd8781ca9163e9f132a4d8392332e64115688013a') as address, 'MATIC' as address_name, 'hop' as project_name union
  select lower('0x10b6CbDFE187c04d63F179B87067C49e7a1E91Af') as address, 'DAI' as address_name, 'hop' as project_name union
  select lower('0x710bDa329b2a6224E4B44833DE30F38E7f81d564') as address, 'ETH' as address_name, 'hop' as project_name union
  select lower('0x881296Edcb252080bd476c464cEB521d08df7631') as address, 'HOP' as address_name, 'hop' as project_name 
union
  select lower('0x5a58505a96d1dbf8df91cb21b54419fc36e93fde') as address, 'token' as address_name, 'wormhole' as project_name union
  select lower('0x7a4b5a56256163f07b2c80a7ca55abe66c4ec4d7') as address, 'poly' as address_name, 'wormhole' as project_name 
union
  select lower('0x48d990AbDA20afa1fD1da713AbC041B60a922c65') as address, 'across' as address_name, 'across' as project_name union
  select lower('0x69B5c72837769eF1e7C164Abc6515DcFf217F920') as address, 'across' as address_name, 'across' as project_name
union
select lower('0x88DCDC47D2f83a99CF0000FDF667A468bB958a78') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0xc1a2D967DfAa6A10f3461bc21864C23C1DD51EeA') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0x4C882ec256823eE773B25b414d36F92ef58a7c0C') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0x4d58FDC7d0Ee9b674F49a0ADE11F26C3c9426F7A') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0xb51541df05DE07be38dcfc4a80c05389A54502BB') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name
union
  select lower('0x4e5eF0CA5A94b169Fb010fb40DBFD57c4830f446') as address, 'poly bridge' as address_name, 'poly bridge' as project_name
),
  to_bridge AS (
  SELECT FROM_ADDRESS as user_address, 
  bridges.project_name as bridge_name, 
  polygon.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(amount,0)) as out_token_volume, 
    SUM(coalesce(amount_usd,0)) as out_usd_volume, 
    COUNT(*) as n_out
  FROM polygon.core.ez_token_transfers
    LEFT JOIN bridges ON polygon.core.ez_token_transfers.TO_ADDRESS = bridges.address 
WHERE 
TO_ADDRESS IN (SELECT address FROM bridges) AND 
 BLOCK_TIMESTAMP >= current_date - 180
GROUP BY user_address, token_contract, bridge_name
    --and FROM_ADDRESS = '0x228406cecfeb7a478ef21fe415800f93019732ae'
),
from_bridge as (
  SELECT TO_ADDRESS as user_address, 
  bridges.project_name as bridge_name, 
  polygon.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(amount,0)) as in_token_volume, 
    SUM(coalesce(amount_usd,0)) as in_usd_volume, 
    COUNT(*) as n_in
  FROM polygon.core.ez_token_transfers
    LEFT JOIN bridges ON polygon.core.ez_token_transfers.FROM_ADDRESS = bridges.address 
WHERE 
FROM_ADDRESS IN (SELECT address FROM bridges) AND 
 BLOCK_TIMESTAMP >= current_date - 180
GROUP BY user_address, token_contract, bridge_name
),
  
to_eth_bridge as (
SELECT TO_ADDRESS as user_address, 
  'Canonical' as bridge_name, 
  CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(amount,0)) as out_token_volume, 
    SUM(coalesce(amount_usd,0)) as out_usd_volume, 
    COUNT(*) as n_out
  FROM ethereum.core.ez_token_transfers
WHERE 
ORIGIN_TO_ADDRESS = lower('0xA0c68C638235ee32657e8f720a23ceC1bFc77C77') AND 
  origin_function_signature = '0x3805550f' and
 BLOCK_TIMESTAMP >= current_date - 180
GROUP BY user_address, token_contract, bridge_name
),
from_eth_bridge as (
 SELECT FROM_ADDRESS as user_address, 
  'Canonical' as bridge_name, 
  CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(amount,0)) as in_token_volume, 
    SUM(coalesce(amount_usd,0)) as in_usd_volume, 
    COUNT(*) as n_in
  FROM ethereum.core.ez_token_transfers
WHERE 
ORIGIN_TO_ADDRESS = lower('0xA0c68C638235ee32657e8f720a23ceC1bFc77C77') AND 
  origin_function_signature in ('0xe3dec8fb') and
 BLOCK_TIMESTAMP >= current_date - 180
GROUP BY user_address, token_contract, bridge_name 
  union
 SELECT eth_FROM_ADDRESS as user_address, 
  'Canonical' as bridge_name, 
  'ETH' as token_contract,
  SUM(coalesce(amount,0)) as in_token_volume, 
    SUM(coalesce(amount_usd,0)) as in_usd_volume, 
    COUNT(*) as n_in
  FROM ethereum.core.ez_eth_transfers
WHERE 
ORIGIN_TO_ADDRESS = lower('0xA0c68C638235ee32657e8f720a23ceC1bFc77C77') AND 
  eth_to_address = lower('0xA0c68C638235ee32657e8f720a23ceC1bFc77C77') and
  origin_function_signature in ('0x4faa8a26') and
  identifier = 'CALL_ORIGIN' and
 BLOCK_TIMESTAMP >= current_date - 180
GROUP BY user_address, token_contract, bridge_name 
),
  
  -- user_address | bridge_name | token_contract | token_symbol | n_in | n_out | in_token_volume | in_usd_volume | out_token_volume | out_usd_volume
allbridge as (
SELECT user_address, bridge_name, token_contract, 
  n_in, n_out, in_token_volume, in_usd_volume, out_token_volume, out_usd_volume  
   FROM from_bridge NATURAL FULL OUTER JOIN to_bridge
union
 SELECT user_address, bridge_name, token_contract, 
  n_in, n_out, in_token_volume, in_usd_volume, out_token_volume, out_usd_volume  
   FROM from_eth_bridge NATURAL FULL OUTER JOIN to_eth_bridge 
)
select user_address,
bridge_name as bridge_name,
token_contract,
sum(n_in) as n_in,
sum(n_out) as n_out,
sum(in_token_volume) as in_token_volume,
sum(in_usd_volume) as in_usd_volume,
sum(out_token_volume) as out_token_volume,
sum(out_usd_volume) as out_usd_volume
from allbridge
group by 1,2,3;