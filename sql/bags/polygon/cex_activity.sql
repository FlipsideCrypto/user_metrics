 WITH cex_addresses AS (
    SELECT ADDRESS, LABEL_TYPE, project_name as label
    FROM polygon.CORE.DIM_LABELS
    WHERE LABEL_TYPE = 'cex'
),
   matic_from_cex AS (
  SELECT NULL as token_contract, 'matic' as token_symbol,
   COUNT(*) as n_withdrawals, SUM(AMOUNT) as wdraw_token_volume, SUM(AMOUNT_USD) as wdraw_usd_volume,
  matic_TO_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM polygon.CORE.EZ_matic_TRANSFERS LEFT JOIN cex_addresses ON matic_FROM_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        matic_FROM_ADDRESS IN (SELECT ADDRESS FROM cex_addresses) AND
        matic_TO_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
   ),
from_cex AS (
  SELECT CONTRACT_ADDRESS as token_contract, SYMBOL as token_symbol,
   COUNT(*) as n_withdrawals, SUM(AMOUNT) as wdraw_token_volume, SUM(AMOUNT_USD) as wdraw_usd_volume,
  TO_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM polygon.CORE.EZ_TOKEN_TRANSFERS LEFT JOIN cex_addresses ON FROM_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        FROM_ADDRESS IN (SELECT ADDRESS FROM cex_addresses) AND
        TO_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
),
to_cex AS (
  SELECT CONTRACT_ADDRESS as token_contract, SYMBOL as token_symbol,
    COUNT(*) as n_deposits, SUM(AMOUNT) as dep_token_volume, SUM(AMOUNT_USD) as dep_usd_volume,
   FROM_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM polygon.CORE.EZ_TOKEN_TRANSFERS LEFT JOIN cex_addresses ON TO_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        FROM_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses) AND
        TO_ADDRESS IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
),
    matic_to_cex AS (
  SELECT NULL as token_contract, 'matic' as token_symbol,
   COUNT(*) as n_deposits, SUM(AMOUNT) as dep_token_volume, SUM(AMOUNT_USD) as dep_usd_volume,
  matic_FROM_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM polygon.CORE.EZ_matic_TRANSFERS LEFT JOIN cex_addresses ON matic_TO_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        matic_FROM_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses) AND
        matic_TO_ADDRESS IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
   )
   
SELECT user_address, exchange_name, token_contract, token_symbol,
   n_deposits, n_withdrawals, dep_token_volume, dep_usd_volume, wdraw_token_volume, wdraw_usd_volume  
   FROM from_cex NATURAL FULL OUTER JOIN to_cex
 UNION (SELECT user_address, exchange_name, token_contract, token_symbol,
   n_deposits, n_withdrawals, dep_token_volume, dep_usd_volume, wdraw_token_volume, wdraw_usd_volume 
   FROM matic_from_cex NATURAL FULL OUTER JOIN matic_to_cex)