-- user_address | bridge_name | token_contract | token_symbol | n_in | n_out | in_token_volume | in_usd_volume | out_token_volume | out_usd_volume
-- PLACE Bridges USING PLACEHOLDER BELOW 

-- looking at defillama's rankings as of april 2023
-- top 2 bridges are multichain and stargate
-- next are celer hop synapse
-- the canonical bridge should also be covered if possible

with bridges as (
    -- multichain addresses
select distinct address, address_name, project_name from optimism.core.dim_labels where project_name = 'multichain' and address_name like '%any%'
union
    -- should cover optimism, polynetwork, hop protocol, synthetix, stargate finance, dforce, celer network, layerzero
select distinct address, address_name, project_name from crosschain.core.address_labels where label_subtype = 'bridge' and blockchain = 'optimism'

),
  to_bridge AS (
  SELECT FROM_ADDRESS as user_address, 
  bridges.project_name as bridge_name, 
  optimism.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(amount,0)) as out_token_volume, 
    SUM(coalesce(amount_usd,0)) as out_usd_volume, 
    COUNT(*) as n_out
  FROM optimism.core.ez_token_transfers
    LEFT JOIN bridges ON optimism.core.ez_token_transfers.TO_ADDRESS = bridges.address 
WHERE 
TO_ADDRESS IN (SELECT address FROM bridges) AND 
 BLOCK_TIMESTAMP >= current_date - 90
GROUP BY user_address, token_contract, bridge_name
    --and FROM_ADDRESS = '0x228406cecfeb7a478ef21fe415800f93019732ae'
),
from_bridge as (
  SELECT TO_ADDRESS as user_address, 
  bridges.project_name as bridge_name, 
  optimism.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  SUM(coalesce(amount,0)) as in_token_volume, 
    SUM(coalesce(amount_usd,0)) as in_usd_volume, 
    COUNT(*) as n_in
  FROM optimism.core.ez_token_transfers
    LEFT JOIN bridges ON optimism.core.ez_token_transfers.FROM_ADDRESS = bridges.address 
WHERE 
FROM_ADDRESS IN (SELECT address FROM bridges) AND 
 BLOCK_TIMESTAMP >= current_date - 90
GROUP BY user_address, token_contract, bridge_name
),
  
  -- user_address | bridge_name | token_contract | token_symbol | n_in | n_out | in_token_volume | in_usd_volume | out_token_volume | out_usd_volume
allbridge as (
SELECT user_address, bridge_name, token_contract, 
  n_in, n_out, in_token_volume, in_usd_volume, out_token_volume, out_usd_volume  
   FROM from_bridge NATURAL FULL OUTER JOIN to_bridge
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