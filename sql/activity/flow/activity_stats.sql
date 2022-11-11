--user_address | n_txn | n_days_active | days_since_last_txn | n_contracts
SELECT
proposer AS user_address,
count(tx_id) AS n_txn,
count(distinct(date_trunc('day', block_timestamp))) AS n_days_active,
DATEDIFF('days', date_trunc('day', max(block_timestamp)), current_date) AS last_txn,
0 AS n_complex_txn,
0 AS n_contracts
FROM flow.core.fact_transactions
WHERE
block_timestamp >= current_date - 180
AND
tx_succeeded = TRUE
AND 
proposer NOT IN (SELECT account_address FROM FLOW.CORE.DIM_CONTRACT_LABELS)
AND
proposer NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow')
GROUP BY
proposer


