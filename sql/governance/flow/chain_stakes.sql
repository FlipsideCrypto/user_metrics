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

stakes AS (
  SELECT
  delegator AS user_address,
  count(tx_id) AS n_stakes,
  sum(amount) AS stake_token_volume,
  sum(amount * price) AS stake_usd_volume
  FROM FLOW.CORE.EZ_STAKING_ACTIONS sa
  JOIN daily_prices dp ON date_trunc('day', sa.block_timestamp) = dp.day
  WHERE 
  block_timestamp >= current_date - 180
  AND
  action = 'DelegatorTokensCommitted'
  GROUP BY user_address
),

unstakes AS (
  SELECT
  delegator AS user_address,
  count(tx_id) AS n_unstakes,
  sum(amount) AS unstake_token_volume,
  sum(amount * price) AS unstake_usd_volume
  FROM FLOW.CORE.EZ_STAKING_ACTIONS sa
  JOIN daily_prices dp ON date_trunc('day', sa.block_timestamp) = dp.day
  WHERE 
  block_timestamp >= current_date - 180
  AND
  action = 'DelegatorUnstakedTokensWithdrawn'
  GROUP BY user_address
)

SELECT
coalesce(s.user_address, u.user_address) AS user_address,
'flow' AS protocol,
'A.16546533918040a61.FlowToken' AS token_contract,
'FlowToken' AS token_symbol,
COALESCE(n_stakes, 0) AS n_stakes,
COALESCE(n_unstakes, 0) AS n_unstakes,
COALESCE(stake_token_volume, 0) AS stake_token_volume,
COALESCE(stake_usd_volume, 0) AS stake_usd_volume,
COALESCE(unstake_token_volume, 0) AS unstake_token_volume,
COALESCE(unstake_usd_volume, 0) AS unstake_usd_volume
FROM stakes s
FULL OUTER JOIN unstakes u ON s.user_address = u.user_address
