WITH labs AS (
SELECT
sender AS address, project_name, 'dep' AS type
FROM FLOW.CORE.EZ_TOKEN_TRANSFERS tt
JOIN FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS al ON tt.recipient = al.address
GROUP BY sender, project_name

  UNION
  
SELECT 
  address, 
  project_name,
  'hot' AS type
  FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS 
  WHERE blockchain = 'flow' AND label_type = 'cex' AND label_subtype = 'hot_wallet'
),
deps AS (
SELECT
  sender AS user_address,
  project_name AS exchange,
  token_contract AS token_contract,
  count(tx_id) AS n_deposits,
  sum(amount) AS token_deposit_volume
  FROM
  flow.core.ez_token_transfers tt
  JOIN 
  labs ON tt.recipient = labs.address
  WHERE
  block_timestamp > current_date - 90
  AND
  tx_succeeded = 'TRUE'
  AND 
  type = 'dep'
  GROUP BY 
  user_address, token_contract, project_name
),
wdraws AS (
SELECT
  recipient AS user_address,
  project_name AS exchange,
  token_contract AS token_contract,
  count(tx_id) AS n_withdrawals,
  sum(amount) AS token_withdrawal_volume
  FROM
  flow.core.ez_token_transfers tt
  JOIN 
  labs ON tt.sender = labs.address
  WHERE
  block_timestamp > current_date - 90
  AND
  tx_succeeded = 'TRUE'
  AND 
  type = 'hot'
  GROUP BY 
  user_address, token_contract, project_name
)

SELECT
COALESCE(ds.user_address, ws.user_address) AS user_address,
COALESCE(ds.exchange, ws.exchange) AS exchange_name,
COALESCE(ds.token_contract, ws.token_contract) AS token_contract,
SPLIT_PART(COALESCE(ds.token_contract, ws.token_contract), '.', 2) AS token_symbol,

COALESCE(n_deposits, 0) AS n_deposits,
COALESCE(n_withdrawals, 0) AS n_withdrawals,

COALESCE(token_deposit_volume, 0) AS dep_token_volume,
0 AS dep_usd_volume,
COALESCE(token_withdrawal_volume, 0) AS wdraw_token_volume,
0 AS wdraw_usd_volume

FROM deps ds
FULL OUTER JOIN wdraws ws ON ds.user_address = ws.user_address
AND ds.token_contract = ws.token_contract

