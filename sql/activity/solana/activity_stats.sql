
SELECT signers[0] AS user_address
, SUM(
    CASE 
        WHEN block_timestamp >= {{start_date}} 
        AND block_timestamp <= {{end_date}}
    THEN 1
    ELSE 0 END
) AS n_txn
, COUNT( DISTINCT CASE 
    WHEN block_timestamp < {{start_date}} THEN NULL
    WHEN block_timestamp > {{end_date}} THEN NULL
    ELSE instructions[0]:programId::string END) AS n_contracts
, SUM( CASE 
    WHEN ARRAY_SIZE(inner_instructions[0]:instructions) IS NULL 
        AND instructions[0]:programId::string IN ('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA','11111111111111111111111111111111')
        AND ARRAY_SIZE(instructions) = 1
        THEN 0  
    WHEN block_timestamp < {{start_date}} THEN 0
    WHEN block_timestamp > {{end_date}} THEN 0
    ELSE 1 END
) AS n_complex_txn
, COUNT(DISTINCT(block_timestamp::date)) AS n_days_active
, MIN(DATEDIFF('days', block_timestamp, CURRENT_TIMESTAMP)) AS days_since_last_txn
FROM solana.core.fact_transactions
GROUP BY 1
