with xfer_in AS (
SELECT TO_ADDRESS as user_address, contract_address as token_contract, SYMBOL as token_symbol, 
  COUNT(*) as n_xfer_in, SUM(AMOUNT) as xfer_in_token_volume, SUM(AMOUNT_USD) as xfer_in_usd_volume
FROM optimism.core.ez_token_transfers
WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-180, 
  CURRENT_DATE())
  GROUP BY user_address, token_contract, TOKEN_SYMBOL
), 

xfer_out AS (
SELECT FROM_ADDRESS as user_address, contract_address as token_contract, SYMBOL as token_symbol, 
  COUNT(*) as n_xfer_out, SUM(AMOUNT) as xfer_out_token_volume, SUM(AMOUNT_USD) as xfer_out_usd_volume
FROM optimism.core.ez_token_transfers
  WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-180, 
    CURRENT_DATE())
  GROUP BY user_address, token_contract, TOKEN_SYMBOL
)

SELECT user_address, token_contract, token_symbol, n_xfer_in, n_xfer_out, xfer_in_token_volume, xfer_in_usd_volume, xfer_out_token_volume, xfer_out_usd_volume
FROM xfer_in NATURAL FULL OUTER JOIN xfer_out 