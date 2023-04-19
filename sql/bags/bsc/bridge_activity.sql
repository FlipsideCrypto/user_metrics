with bridges as (
select distinct address, address_name, project_name from bsc.core.dim_labels where project_name = 'multichain' and address_name like '%any%'
union
select lower('0x9aA83081AA06AF7208Dcc7A4cB72C94d057D2cda') as address, 'USDT' as address_name, 'stargate' as project_name union
  select lower('0x98a5737749490856b401DB5Dc27F522fC314A4e1') as address, 'BUSD' as address_name, 'stargate' as project_name union
  select lower('0x4e145a589e4c03cBe3d28520e4BF3089834289Df') as address, 'USDD' as address_name, 'stargate' as project_name union
  select lower('0x7BfD7f2498C4796f10b6C611D9db393D3052510C') as address, 'MAI' as address_name, 'stargate' as project_name union
  select lower('0xD4CEc732b3B135eC52a3c0bc8Ce4b8cFb9dacE46') as address, 'METIS' as address_name, 'stargate' as project_name union
  select lower('0x68C6c27fB0e02285829e69240BE16f32C5f8bEFe') as address, 'metis.USDT' as address_name, 'stargate' as project_name
union
  select lower('0x4b3B4120d4D7975455d8C2894228789c91a247F8') as address, 'anyswap' as address_name, 'anyswap' as project_name
union
  select lower('0xB6F6D86a8f9879A9c87f643768d9efc38c1Da6E7') as address, 'wormhole' as address_name, 'wormhole' as project_name
union
select lower('0xdd90E5E87A2081Dcf0391920868eBc2FFB81a1aF') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0x78bc5Ee9F11d133A08b331C2e18fE81BE0Ed02DC') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0x11a0c9270D88C99e221360BCA50c2f6Fda44A980') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0xd443FE6bf23A4C9B78312391A30ff881a097580E') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name union
  select lower('0x26c76F7FeF00e02a5DD4B5Cc8a0f717eB61e1E4b') as address, 'celer bridge' as address_name, 'celer_bridge' as project_name
union
  select lower('0x2f7ac9436ba4B548f9582af91CA1Ef02cd2F1f03') as address, 'poly bridge' as address_name, 'poly bridge' as project_name
),
  to_bridge AS (
  SELECT FROM_ADDRESS as user_address, 
  bridges.project_name as bridge_name, 
  bsc.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(raw_amount/pow(10,18),0)) as out_token_volume, 
    SUM(coalesce((raw_amount/pow(10,18))*token_price,0)) as out_usd_volume, 
    COUNT(*) as n_out
  FROM bsc.core.ez_token_transfers
    LEFT JOIN bridges ON bsc.core.ez_token_transfers.TO_ADDRESS = bridges.address 
WHERE 
TO_ADDRESS IN (SELECT address FROM bridges) AND 
 BLOCK_TIMESTAMP >= current_date - 180
GROUP BY user_address, token_contract, bridge_name 
),
from_bridge as (
  SELECT TO_ADDRESS as user_address, 
  bridges.project_name as bridge_name, 
  bsc.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(raw_amount/pow(10,18),0)) as in_token_volume, 
    SUM(coalesce((raw_amount/pow(10,18))*token_price,0)) as in_usd_volume, 
    COUNT(*) as n_in
  FROM bsc.core.ez_token_transfers
    LEFT JOIN bridges ON bsc.core.ez_token_transfers.FROM_ADDRESS = bridges.address 
WHERE 
FROM_ADDRESS IN (SELECT address FROM bridges) AND 
 BLOCK_TIMESTAMP >= current_date - 180
GROUP BY user_address, token_contract, bridge_name
)
  
  -- user_address | bridge_name | token_contract | token_symbol | n_in | n_out | in_token_volume | in_usd_volume | out_token_volume | out_usd_volume
SELECT user_address, bridge_name, token_contract, 
  n_in, n_out, in_token_volume, in_usd_volume, out_token_volume, out_usd_volume  
   FROM from_bridge NATURAL FULL OUTER JOIN to_bridge
