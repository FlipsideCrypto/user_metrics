-- user_address | protocol | token_contract | token_symbol | 
-- n_buys | n_sells | buy_token_volume | buy_usd_volume | sell_token_volume | sell_usd_volume

with trades_in AS (
SELECT ORIGIN_FROM_ADDRESS as user_address, PLATFORM as protocol, TOKEN_IN as token_contract, SYMBOL_IN as token_symbol, 
  COUNT(*) as n_sells, SUM(AMOUNT_IN) as sell_token_volume, SUM(AMOUNT_IN_USD) as sell_usd_volume
FROM polygon.CORE.EZ_DEX_SWAPS
WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-90, 
  CURRENT_DATE())
  GROUP BY user_address, protocol, token_contract, TOKEN_SYMBOL
), 

trades_out AS (
SELECT ORIGIN_FROM_ADDRESS as user_address, PLATFORM as protocol, TOKEN_OUT as token_contract, SYMBOL_OUT as token_symbol,
  COUNT(*) as n_buys, SUM(AMOUNT_OUT) as buy_token_volume, SUM(AMOUNT_OUT_USD) as buy_usd_volume
FROM polygon.CORE.EZ_DEX_SWAPS
  WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-90, 
   CURRENT_DATE())
  GROUP BY user_address, protocol, token_contract, TOKEN_SYMBOL
)

SELECT user_address, protocol, token_contract, token_symbol, 
 n_buys, n_sells, buy_token_volume, buy_usd_volume, sell_token_volume, sell_usd_volume
FROM trades_in NATURAL FULL OUTER JOIN trades_out 
