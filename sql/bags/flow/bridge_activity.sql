WITH inbound AS (
  SELECT
  flow_wallet_address AS user_address,
  token_contract AS token_contract,
  bridge,
  count(tx_id) AS n_inbound_bridge,
  sum(amount) AS inbound_bridge_volume
  FROM
  flow.core.fact_bridge_transactions
  WHERE
  block_timestamp > current_date - 90
  AND 
  direction = 'inbound'
  GROUP BY 
  user_address, token_contract, bridge
),
outbound AS (
  SELECT
  flow_wallet_address AS user_address,
  token_contract AS token_contract,
  bridge,
  count(tx_id) AS n_outbound_bridge,
  sum(amount) AS outbound_bridge_volume
  FROM
  flow.core.fact_bridge_transactions
  WHERE
  block_timestamp > current_date - 90
  AND 
  direction = 'outbound'
  GROUP BY 
  user_address, token_contract, bridge
)

SELECT
COALESCE(ib.user_address, ob.user_address) AS user_address,
COALESCE(ib.bridge, ob.bridge) AS bridge_name,
COALESCE(ib.token_contract, ob.token_contract) AS token_contract,
SPLIT_PART(COALESCE(ib.token_contract, ob.token_contract), '.', 2) AS token_symbol,
COALESCE(n_inbound_bridge, 0) AS n_in,
COALESCE(n_outbound_bridge, 0) AS n_out,
COALESCE(inbound_bridge_volume, 0) AS in_token_volume,
0 AS in_usd_volume,
COALESCE(outbound_bridge_volume, 0) AS out_token_volume,
0 AS out_usd_volume
FROM inbound ib
FULL OUTER JOIN outbound ob ON ib.user_address = ob.user_address
AND ib.token_contract = ob.token_contract
AND ib.bridge = ob.bridge


