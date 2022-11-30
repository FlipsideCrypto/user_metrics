-- user_address | bridge_name | token_contract | token_symbol | n_in | n_out | in_token_volume | in_usd_volume | out_token_volume | out_usd_volume

-- PLACE Bridges USING PLACEHOLDER BELOW 
with bridges AS (
  -- HOP USDC Bridge
SELECT 'Hop' as bridge, LOWER('0x3666f603Cc164936C1b87e207F36BEBa4AC5f18a') as BRIDGE_ADDRESS, LOWER('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48') as CONTRACT_ADDRESS, 'USDC' as SYMBOL FROM DUAL 
UNION
  -- HOP USDT Bridge 
  SELECT 'Hop' as bridge, LOWER('0x3E4a3a4796d16c0Cd582C382691998f7c06420B6') as BRIDGE_ADDRESS, LOWER('0xdAC17F958D2ee523a2206206994597C13D831ec7') as CONTRACT_ADDRESS,'USDT' as SYMBOL FROM DUAL 
UNION
 -- HOP MATIC Bridge
 SELECT 'Hop' as bridge, LOWER('0x22B1Cbb8D98a01a3B71D034BB899775A76Eb1cc2') as BRIDGE_ADDRESS, LOWER('0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0') as CONTRACT_ADDRESS, 'MATIC' as SYMBOL FROM DUAL
  UNION
 -- HOP DAI Bridge
 SELECT 'Hop' as bridge, LOWER('0x3d4Cc8A61c7528Fd86C55cfe061a78dCBA48EDd1') as BRIDGE_ADDRESS, LOWER('0x6B175474E89094C44Da98b954EedeAC495271d0F') as CONTRACT_ADDRESS, 'DAI' as SYMBOL FROM DUAL
  UNION
 -- HOP ETH Bridge
 SELECT 'Hop' as bridge, LOWER('0xb8901acB165ed027E32754E0FFe830802919727f') as BRIDGE_ADDRESS, NULL as CONTRACT_ADDRESS, 'ETH' as SYMBOL FROM DUAL
  UNION
 -- HOP WBTC Bridge
 SELECT 'Hop' as bridge, LOWER('0xb98454270065A31D71Bf635F6F7Ee6A518dFb849') as BRIDGE_ADDRESS, LOWER('0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599') as CONTRACT_ADDRESS, 'WBTC' as SYMBOL FROM DUAL
  UNION
 -- HOP HOP Bridge
 SELECT 'Hop' as bridge, LOWER('0x914f986a44AcB623A277d6Bd17368171FCbe4273') as BRIDGE_ADDRESS, LOWER('0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC') as CONTRACT_ADDRESS, 'HOP' as SYMBOL FROM DUAL
  UNION
 -- HOP SNX Bridge
 SELECT 'Hop' as bridge, LOWER('0x893246FACF345c99e4235E5A7bbEE7404c988b96') as BRIDGE_ADDRESS, LOWER('0xc011a73ee8576fb46f5e1c5751ca3b9fe0af2a6f') as CONTRACT_ADDRESS, 'SNX' as SYMBOL FROM DUAL
UNION
 -- HOP sUSD Bridge
 SELECT 'Hop' as bridge, LOWER('0x36443fC70E073fe9D50425f82a3eE19feF697d62') as BRIDGE_ADDRESS, LOWER('0x57Ab1ec28D129707052df4dF418D58a2D46d5f51') as CONTRACT_ADDRESS, 'sUSD' as SYMBOL FROM DUAL
  
/*
UNION
 -- BRIDGE TOKEN Bridge
 SELECT 'BRIDGE' as bridge, LOWER('BRIDGE_ADDRESS') as BRIDGE_ADDRESS, LOWER('') as CONTRACT_ADDRESS, 'TOKENSYMBOL' as SYMBOL FROM DUAL
*/
    
),

to_bridge AS (
  SELECT FROM_ADDRESS as user_address, 
  bridges.bridge as bridge_name, 
  ethereum.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  ethereum.core.ez_token_transfers.SYMBOL as token_symbol,
  SUM(AMOUNT) as out_token_volume, SUM(AMOUNT_USD) as out_usd_volume, COUNT(*) as n_out
  FROM ethereum.core.ez_token_transfers LEFT JOIN bridges ON ethereum.core.ez_token_transfers.TO_ADDRESS = bridges.BRIDGE_ADDRESS 
WHERE ethereum.core.ez_token_transfers.CONTRACT_ADDRESS IN (SELECT CONTRACT_ADDRESS FROM bridges) AND 
TO_ADDRESS IN (SELECT BRIDGE_ADDRESS FROM bridges) AND 
 BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
   CURRENT_DATE())
GROUP BY user_address, token_contract, token_symbol, bridge_name 
),

to_bridge_eth AS ( 
SELECT ETH_FROM_ADDRESS as user_address, 
   bridges.bridge as bridge_name, 
  NULL as token_contract, 
  'ETH' as token_symbol, 
  SUM(AMOUNT) as out_token_volume, SUM(AMOUNT_USD) as out_usd_volume, COUNT(*) as n_out
  FROM ethereum.core.ez_eth_transfers LEFT JOIN bridges ON ethereum.core.ez_eth_transfers.ETH_TO_ADDRESS = bridges.BRIDGE_ADDRESS
WHERE ETH_TO_ADDRESS IN (SELECT BRIDGE_ADDRESS FROM bridges) AND 
 BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
   CURRENT_DATE())
  GROUP BY user_address, token_contract, token_symbol, bridge_name
),

from_bridge AS ( 
  SELECT TO_ADDRESS as user_address, 
  bridges.bridge as bridge_name, 
  ethereum.core.ez_token_transfers.CONTRACT_ADDRESS as token_contract,
  ethereum.core.ez_token_transfers.SYMBOL as token_symbol,
  SUM(AMOUNT) as in_token_volume, SUM(AMOUNT_USD) as in_usd_volume,  COUNT(*) as n_in
  FROM ethereum.core.ez_token_transfers LEFT JOIN bridges ON ethereum.core.ez_token_transfers.FROM_ADDRESS = bridges.BRIDGE_ADDRESS 
WHERE ethereum.core.ez_token_transfers.CONTRACT_ADDRESS IN (SELECT CONTRACT_ADDRESS FROM bridges) AND 
FROM_ADDRESS IN (SELECT BRIDGE_ADDRESS FROM bridges) AND 
 BLOCK_TIMESTAMP >= DATEADD('day', 
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
  CURRENT_DATE())
GROUP BY user_address, token_contract, token_symbol, bridge_name 
),

from_bridge_eth AS (
SELECT ETH_TO_ADDRESS as user_address, 
   bridges.bridge as bridge_name, 
  NULL as token_contract, 
  'ETH' as token_symbol, 
  SUM(AMOUNT) as in_token_volume, SUM(AMOUNT_USD) as in_usd_volume, COUNT(*) as n_in
  FROM ethereum.core.ez_eth_transfers LEFT JOIN bridges ON ethereum.core.ez_eth_transfers.ETH_FROM_ADDRESS = bridges.BRIDGE_ADDRESS
WHERE ETH_FROM_ADDRESS IN (SELECT BRIDGE_ADDRESS FROM bridges) AND 
 BLOCK_TIMESTAMP >= DATEADD('day', 
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
 CURRENT_DATE())
  GROUP BY user_address, token_contract, token_symbol, bridge_name
)
  
  -- user_address | bridge_name | token_contract | token_symbol | n_in | n_out | in_token_volume | in_usd_volume | out_token_volume | out_usd_volume
SELECT user_address, bridge_name, token_contract, token_symbol, 
  n_in, n_out, in_token_volume, in_usd_volume, out_token_volume, out_usd_volume  
   FROM from_bridge NATURAL FULL OUTER JOIN to_bridge
 UNION (SELECT user_address, bridge_name, token_contract, token_symbol,
  n_in, n_out, in_token_volume, in_usd_volume, out_token_volume, out_usd_volume  
   FROM from_bridge_eth NATURAL FULL OUTER JOIN to_bridge_eth)

