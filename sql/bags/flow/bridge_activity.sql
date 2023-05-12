WITH daily_prices AS (
SELECT 
  token as symbol,
  id as token_contract,
  date_trunc('day', recorded_hour) AS day,
  AVG(close) AS price
FROM flow.core.fact_hourly_prices
WHERE recorded_hour > current_date - 91
GROUP BY symbol, token_contract, day
),
inbound AS (
  SELECT
  flow_wallet_address AS user_address,
  symbol,
  bt.token_contract AS token_contract,
  bridge,
  count(tx_id) AS n_inbound_bridge,
  sum(amount) AS inbound_token_volume,
  sum(amount * price) AS inbound_usd_volume
  FROM
  flow.core.ez_bridge_transactions bt
  JOIN daily_prices dp ON date_trunc('day', bt.block_timestamp) = dp.day
    AND bt.token_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  AND 
  direction = 'inbound'
  GROUP BY 
  user_address, symbol, bt.token_contract, bridge),
outbound AS (
  SELECT
  flow_wallet_address AS user_address,
  symbol,
  bt.token_contract AS token_contract,
  bridge,
  count(tx_id) AS n_outbound_bridge,
  sum(amount) AS outbound_token_volume,
  sum(amount * price) AS outbound_usd_volume
  FROM
  flow.core.ez_bridge_transactions bt
  JOIN daily_prices dp ON date_trunc('day', bt.block_timestamp) = dp.day
    AND bt.token_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  AND 
  direction = 'outbound'
  GROUP BY 
  user_address, symbol, bt.token_contract, bridge
 )
 
SELECT
COALESCE(ib.user_address, ob.user_address) AS user_address,
COALESCE(ib.bridge, ob.bridge) AS bridge_name,
COALESCE(ib.token_contract, ob.token_contract) AS token_contract,
COALESCE(ib.symbol, ob.symbol) AS token_symbol,
COALESCE(n_inbound_bridge, 0) AS n_in,
COALESCE(n_outbound_bridge, 0) AS n_out,
COALESCE(inbound_token_volume, 0) AS in_token_volume,
COALESCE(inbound_usd_volume, 0) AS in_usd_volume,
COALESCE(outbound_token_volume, 0) AS out_token_volume,
COALESCE(outbound_usd_volume, 0) AS out_usd_volume
FROM inbound ib
FULL OUTER JOIN outbound ob ON ib.user_address = ob.user_address
AND ib.token_contract = ob.token_contract
AND ib.bridge = ob.bridge
 
 
 
 
 
