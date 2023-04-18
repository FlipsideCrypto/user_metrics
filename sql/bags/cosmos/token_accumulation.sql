WITH ins AS (
SELECT 
  sender AS user_address, 
  currency AS token_contract, 
  t.project_name AS token_symbol,
  count(*) AS n_xfer_in, 
  SUM(amount / POW(10, t.decimal)) AS xfer_in_token_volume, 
  SUM((amount / POW(10, t.decimal))*price) AS xfer_in_usd_volume
FROM cosmos.core.fact_transfers l
INNER JOIN osmosis.core.dim_tokens t ON l.currency = t.address
INNER JOIN osmosis.core.dim_prices p ON date_trunc('hour', l.block_timestamp) = p.recorded_at
AND t.project_name = p.symbol
WHERE block_timestamp :: date >= CURRENT_DATE - 90 
AND (transfer_type = 'IBC_TRANSFER_IN' OR transfer_type = 'COSMOS')
GROUP BY user_address, token_contract, token_symbol
), 
outs AS (
  SELECT 
  sender AS user_address, 
  currency AS token_contract, 
  t.project_name AS token_symbol,
  count(*) AS n_xfer_out, 
  SUM(amount / POW(10, t.decimal)) AS xfer_out_token_volume, 
  SUM((amount / POW(10, t.decimal))*price) AS xfer_out_usd_volume
FROM cosmos.core.fact_transfers l
INNER JOIN osmosis.core.dim_tokens t ON l.currency = t.address
INNER JOIN osmosis.core.dim_prices p ON date_trunc('hour', l.block_timestamp) = p.recorded_at
AND t.project_name = p.symbol
WHERE block_timestamp :: date >= CURRENT_DATE - 90 
AND transfer_type = 'IBC_TRANSFER_OUT'
GROUP BY user_address, token_contract, token_symbol
)
SELECT 
  user_address, 
  token_contract, 
  token_symbol, 
  n_xfer_in, 
  n_xfer_out, 
  xfer_in_token_volume, 
  xfer_in_usd_volume,
  xfer_out_token_volume,
  xfer_out_usd_volume
FROM ins
NATURAL FULL JOIN outs