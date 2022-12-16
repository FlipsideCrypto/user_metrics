SELECT
  tx_sender AS user_address,
  COUNT(1) AS n_txn,
  COUNT(
    DISTINCT block_timestamp :: DATE
  ) AS n_days_active,
  MIN(
    DATEDIFF(
      'days',
      block_timestamp,
      CURRENT_TIMESTAMP
    )
  ) AS days_since_last_txn,
  COUNT(
    DISTINCT CASE
      WHEN tx_type = 'pay' THEN NULL
      ELSE COALESCE(
        tx_group_ID,
        tx_id
      )
    END
  ) AS n_complex_txn,
  COUNT(
    DISTINCT app_id
  ) AS n_contracts
FROM
  algorand.core.fact_transaction t
  JOIN algorand.core.dim_transaction_type tt
  ON t.dim_transaction_type_id = tt.dim_transaction_type_id
WHERE
  DATE_TRUNC(
    'DAY',
    block_timestamp
  ) >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE())
GROUP BY
  user_address
