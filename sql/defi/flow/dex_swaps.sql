WITH daily_prices AS (
SELECT 
  symbol,
  token_contract,
  date_trunc('day', timestamp) AS day,
  AVG(price_usd) AS price
FROM flow.core.fact_prices
WHERE timestamp > current_date - 180
GROUP BY symbol, token_contract, day
),
sells AS (
  SELECT
  trader AS user_address,
  symbol,
  swap_contract,
  token_out_contract AS token_contract,
  count(tx_id) AS n_sells,
  sum(token_out_amount) AS token_sell_volume,
  sum(token_out_amount * price) AS usd_sell_volume
  FROM
  flow.core.ez_swaps ds
  LEFT JOIN daily_prices dp ON date_trunc('day', ds.block_timestamp) = dp.day
      AND ds.token_out_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  trader, swap_contract, symbol, token_out_contract
),
buys AS (
  SELECT
  trader AS user_address,
  symbol,
  swap_contract,
  token_in_contract AS token_contract,
  count(tx_id) AS n_buys,
  sum(token_in_amount) AS token_buy_volume,
  sum(token_in_amount * price) AS usd_buy_volume
  FROM
  flow.core.ez_swaps ds
  LEFT JOIN daily_prices dp ON date_trunc('day', ds.block_timestamp) = dp.day
      AND ds.token_in_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  trader, swap_contract, symbol, token_in_contract
)

SELECT
COALESCE(sells.user_address, buys.user_address) AS user_address,
COALESCE(sells.swap_contract, buys.swap_contract) AS protocol,
COALESCE(sells.token_contract, buys.token_contract) AS token_contract,
COALESCE(sells.symbol, buys.symbol) AS token_symbol,
COALESCE(n_buys, 0) AS n_buys,
COALESCE(n_sells, 0) AS n_sells,
COALESCE(token_buy_volume, 0) AS buy_token_volume,
COALESCE(usd_buy_volume, 0) AS buy_usd_volume,
COALESCE(token_sell_volume, 0) AS sell_token_volume,
COALESCE(usd_sell_volume, 0) AS sell_usd_volume
FROM sells
FULL OUTER JOIN buys ON sells.user_address = buys.user_address
AND sells.swap_contract = buys.swap_contract
AND sells.token_contract = buys.token_contract
