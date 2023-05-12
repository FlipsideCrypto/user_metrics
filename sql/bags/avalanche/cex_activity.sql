 WITH cex_addresses AS (
    SELECT ADDRESS, LABEL_TYPE, project_name as label
    FROM avalanche.CORE.DIM_LABELS
    WHERE LABEL_TYPE = 'cex'
),
   avax_from_cex AS (
  SELECT NULL as token_contract, 'avax' as token_symbol,
   COUNT(*) as n_withdrawals, SUM(AMOUNT) as wdraw_token_volume, SUM(AMOUNT_USD) as wdraw_usd_volume,
  avax_TO_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM avalanche.CORE.EZ_avax_TRANSFERS LEFT JOIN cex_addresses ON avax_FROM_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        avax_FROM_ADDRESS IN (SELECT ADDRESS FROM cex_addresses) AND
        avax_TO_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
   ),
from_cex AS (
  SELECT CONTRACT_ADDRESS as token_contract, SYMBOL as token_symbol,
   COUNT(*) as n_withdrawals, SUM(AMOUNT) as wdraw_token_volume, SUM(AMOUNT_USD) as wdraw_usd_volume,
  TO_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM avalanche.CORE.EZ_TOKEN_TRANSFERS LEFT JOIN cex_addresses ON FROM_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        FROM_ADDRESS IN (SELECT ADDRESS FROM cex_addresses) AND
        TO_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
),
to_cex AS (
  SELECT CONTRACT_ADDRESS as token_contract, SYMBOL as token_symbol,
    COUNT(*) as n_deposits, SUM(AMOUNT) as dep_token_volume, SUM(AMOUNT_USD) as dep_usd_volume,
   FROM_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM avalanche.CORE.EZ_TOKEN_TRANSFERS LEFT JOIN cex_addresses ON TO_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        FROM_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses) AND
        TO_ADDRESS IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
),
    avax_to_cex AS (
  SELECT NULL as token_contract, 'avax' as token_symbol,
   COUNT(*) as n_deposits, SUM(AMOUNT) as dep_token_volume, SUM(AMOUNT_USD) as dep_usd_volume,
  avax_FROM_ADDRESS as user_address, cex_addresses.LABEL as exchange_name
  FROM avalanche.CORE.EZ_avax_TRANSFERS LEFT JOIN cex_addresses ON avax_TO_ADDRESS = cex_addresses.ADDRESS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) AND
        avax_FROM_ADDRESS NOT IN (SELECT ADDRESS FROM cex_addresses) AND
        avax_TO_ADDRESS IN (SELECT ADDRESS FROM cex_addresses)
GROUP BY user_address, exchange_name, token_contract, token_symbol
   )
   
SELECT user_address, exchange_name, token_contract, token_symbol,
   n_deposits, n_withdrawals, dep_token_volume, dep_usd_volume, wdraw_token_volume, wdraw_usd_volume  
   FROM from_cex NATURAL FULL OUTER JOIN to_cex
 UNION (SELECT user_address, exchange_name, token_contract, token_symbol,
   n_deposits, n_withdrawals, dep_token_volume, dep_usd_volume, wdraw_token_volume, wdraw_usd_volume 
   FROM avax_from_cex NATURAL FULL OUTER JOIN avax_to_cex)