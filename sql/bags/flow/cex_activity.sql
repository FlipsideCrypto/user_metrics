WITH dep_addys AS (
  SELECT
  sender
  FROM FLOW.CORE.EZ_TOKEN_TRANSFERS
  WHERE recipient IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow' AND label_type = 'cex' AND label_subtype = 'hot_wallet')
  GROUP BY sender
),
deps AS (
SELECT
  sender AS user_address,
  token_contract AS token_contract,
  count(tx_id) AS n_deposits,
  sum(amount) AS token_deposit_volume
  FROM
  flow.core.ez_token_transfers
  WHERE
  block_timestamp > current_date - 90
  AND
  tx_succeeded = 'TRUE'
  AND 
  recipient IN (SELECT sender FROM dep_addys)
  GROUP BY 
  user_address, token_contract
),
wdraws AS (
  SELECT
  recipient AS user_address,
  token_contract AS token_contract,
  count(tx_id) AS n_withdrawals,
  sum(amount) AS token_withdrawal_volume
  FROM
  flow.core.ez_token_transfers
  WHERE
  block_timestamp > current_date - 90
  AND
  tx_succeeded = 'TRUE'
  AND 
  sender IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow' AND label_type = 'cex' AND label_subtype = 'hot_wallet')
  GROUP BY 
  user_address, token_contract
)

SELECT
COALESCE(ds.user_address, ws.user_address) AS user_address,
COALESCE(ds.token_contract, ws.token_contract) AS token_contract,
COALESCE(n_deposits, 0) AS n_deposits,
COALESCE(token_deposit_volume, 0) AS token_deposit_volume,
COALESCE(n_withdrawals, 0) AS n_withdrawals,
COALESCE(token_withdrawal_volume, 0) AS token_withdrawal_volume
FROM deps ds
FULL OUTER JOIN wdraws ws ON ds.user_address = ws.user_address
AND ds.token_contract = ws.token_contract