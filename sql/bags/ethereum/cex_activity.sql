-- user_address | exchange_name | token_contract | token_symbol | n_deposits | n_withdrawals | dep_token_volume | dep_usd_volume | wdraw_token_volume | wdraw_usd_volume

 WITH cex_addresses AS (
    SELECT ADDRESS, LABEL_TYPE, LABEL
    FROM ETHEREUM.CORE.DIM_LABELS
    WHERE LABEL_TYPE = 'cex'
),

   eth_from_cex AS (
  SELECT NULL as token_contract, 'ETH' as token_symbol,
   COUNT(*) as n_withdrawals, SUM(AMOUNT) as wdraw_token_volume, SUM(AMOUNT_USD) as wdraw_usd_volume,
  ETH_TO_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM ETHEREUM.CORE.EZ_ETH_TRANSFERS LEFT JOIN cex_addresses ON ETH_FROM_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', 
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
  CURRENT_DATE()) AND
        ETH_FROM_ADDRESS IN (SELECT ADDRESS FROM cex_addresses) AND
        ETH_TO_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
   ),
from_cex AS (
  SELECT CONTRACT_ADDRESS as token_contract, SYMBOL as token_symbol,
   COUNT(*) as n_withdrawals, SUM(AMOUNT) as wdraw_token_volume, SUM(AMOUNT_USD) as wdraw_usd_volume,
  TO_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM ETHEREUM.CORE.EZ_TOKEN_TRANSFERS LEFT JOIN cex_addresses ON FROM_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
   CURRENT_DATE()) AND
        FROM_ADDRESS IN (SELECT ADDRESS FROM cex_addresses) AND
        TO_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
),
to_cex AS (
  SELECT CONTRACT_ADDRESS as token_contract, SYMBOL as token_symbol,
    COUNT(*) as n_deposits, SUM(AMOUNT) as dep_token_volume, SUM(AMOUNT_USD) as dep_usd_volume,
   FROM_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM ETHEREUM.CORE.EZ_TOKEN_TRANSFERS LEFT JOIN cex_addresses ON TO_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', 
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
  CURRENT_DATE()) AND
        FROM_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses) AND
        TO_ADDRESS IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
),
    eth_to_cex AS (
  SELECT NULL as token_contract, 'ETH' as token_symbol,
   COUNT(*) as n_deposits, SUM(AMOUNT) as dep_token_volume, SUM(AMOUNT_USD) as dep_usd_volume,
  ETH_FROM_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM ETHEREUM.CORE.EZ_ETH_TRANSFERS LEFT JOIN cex_addresses ON ETH_TO_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
    CURRENT_DATE()) AND
        ETH_FROM_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses) AND
        ETH_TO_ADDRESS IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
   ), 
   
SELECT user_address, exchange_name, token_contract, token_symbol,
   n_deposits, n_withdrawals, dep_token_volume, dep_usd_volume, wdraw_token_volume, wdraw_usd_volume  
   FROM from_cex NATURAL FULL OUTER JOIN to_cex
 UNION (SELECT user_address, exchange_name, token_contract, token_symbol,
   n_deposits, n_withdrawals, dep_token_volume, dep_usd_volume, wdraw_token_volume, wdraw_usd_volume 
   FROM eth_from_cex NATURAL FULL OUTER JOIN eth_to_cex)

