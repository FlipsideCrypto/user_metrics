SELECT
    from_address AS user_address,
    COUNT(1) AS n_txn,
    COUNT(DISTINCT(DATE_TRUNC('DAY', block_timestamp))) AS n_days_active,
    DATEDIFF(DAY, MAX(block_timestamp), CURRENT_DATE()) AS days_since_last_txn,
    -- a complex tx is any tx that is NOT a simple ETH transfer; i.e., has input data!
    count_if(
        input_data != '0x'
    ) AS n_complex_txn,
    COUNT (
        DISTINCT CASE
            WHEN input_data != '0x' THEN to_address
        END
    ) AS n_contracts
FROM
    optimism.core.fact_transactions
WHERE
    block_timestamp >= DATEADD(
        'day',
        -180,
        CURRENT_DATE()
    )
GROUP BY
    from_address
