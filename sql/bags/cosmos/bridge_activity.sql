WITH ins AS (
SELECT 
  sender AS user_address, 
  'IBC' AS bridge_name, 
  currency AS token_contract, 
  t.project_name AS token_symbol,
  count(*) AS n_in, 
  SUM(amount / POW(10, t.decimal)) AS in_token_volume, 
  SUM((amount / POW(10, t.decimal))*price) AS in_usd_volume
FROM cosmos.core.fact_transfers l
INNER JOIN osmosis.core.dim_tokens t ON l.currency = t.address
INNER JOIN osmosis.core.dim_prices p ON date_trunc('hour', l.block_timestamp) = p.recorded_at
AND t.project_name = p.symbol
WHERE block_timestamp :: date >= CURRENT_DATE - 90 
AND transfer_type = 'IBC_TRANSFER_IN'
GROUP BY user_address, bridge_name, token_contract, token_symbol
), 
outs AS (
  SELECT 
  sender AS user_address, 
  'IBC' AS bridge_name, 
  currency AS token_contract, 
  t.project_name AS token_symbol,
  count(*) AS n_out, 
  SUM(amount / POW(10, t.decimal)) AS out_token_volume, 
  SUM((amount / POW(10, t.decimal))*price) AS out_usd_volume
FROM cosmos.core.fact_transfers l
INNER JOIN osmosis.core.dim_tokens t ON l.currency = t.address
INNER JOIN osmosis.core.dim_prices p ON date_trunc('hour', l.block_timestamp) = p.recorded_at
AND t.project_name = p.symbol
WHERE block_timestamp :: date >= CURRENT_DATE - 90 
AND transfer_type = 'IBC_TRANSFER_OUT'
GROUP BY user_address, bridge_name, token_contract, token_symbol
)
SELECT 
  user_address, 
  bridge_name, 
  token_contract, 
  token_symbol, 
  n_in, 
  n_out, 
  in_token_volume, 
  in_usd_volume,
  out_token_volume,
  out_usd_volume
FROM ins
NATURAL FULL JOIN outs