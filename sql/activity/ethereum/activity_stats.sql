SELECT FROM_ADDRESS as user_address,
  COUNT(*) as n_txn,
 count(DISTINCT(date_trunc('DAY', block_timestamp))) as n_days_active,
  DATEDIFF(day, MAX(BLOCK_TIMESTAMP), CURRENT_DATE()) as days_since_last_txn,
  -- a complex tx is any tx that is NOT a simple ETH transfer; i.e., has input data!
 count_if(INPUT_DATA != '0x') as n_complex_txn,
 COUNT (DISTINCT CASE WHEN INPUT_DATA != '0x' THEN TO_ADDRESS END) as n_contracts
 FROM ethereum.core.fact_transactions
  WHERE 
BLOCK_TIMESTAMP >= DATEADD('day', 
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
 CURRENT_DATE())
GROUP BY FROM_ADDRESS


SELECT min(BLOCK_NUMBER) FROM ethereum.core.fact_transactions 
WHERE BLOCK_TIMESTAMP >= DATEADD('day', -{{last_n_days}}, CURRENT_DATE())
