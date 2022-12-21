WITH base_stats AS (
    SELECT
        DISTINCT tx_from AS user_address,
        COUNT(*) AS n_txn,
        COUNT(DISTINCT DATE_TRUNC('DAY', t.block_timestamp)) AS n_days_active,
        MIN(
            DATEDIFF(
                'days',
                t.block_timestamp,
                CURRENT_TIMESTAMP
            )
        ) AS days_since_last_txn,
        COUNT(
            DISTINCT attribute_value
        ) AS n_contracts
    FROM
        osmosis.core.fact_transactions t
        LEFT OUTER JOIN osmosis.core.fact_msg_attributes m
        ON t.tx_id = m.tx_id
    WHERE
        t.block_timestamp :: DATE >= CURRENT_DATE - 90
        AND m.block_timestamp :: DATE >= CURRENT_DATE - 90
        AND attribute_key = 'module'
    GROUP BY
        tx_from
),
complex_txs AS (
    SELECT
        tx_from AS user_address,
        COUNT(
            DISTINCT tx_id
        ) AS n_complex_txn
    FROM
        osmosis.core.fact_transactions
    WHERE
        block_timestamp :: DATE >= CURRENT_DATE - 90
        AND tx_id NOT IN (
            SELECT
                tx_id
            FROM
                osmosis.core.fact_transfers
            WHERE
                transfer_type = 'OSMOSIS'
        )
    GROUP BY
        tx_from
)
SELECT
    b.user_address,
    n_txn,
    n_days_active,
    days_since_last_txn,
    n_complex_txn,
    n_contracts
FROM
    base_stats b
    INNER JOIN complex_txs C
    ON b.user_address = C.user_address
