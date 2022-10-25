select A.tx_signer as user_address,
SUM( CASE WHEN A.block_timestamp >= (current_date - 90) THEN 1 ELSE 0 END) AS n_txn,
COUNT(DISTINCT(A.block_timestamp::date)) AS n_days_active,
MIN(DATEDIFF('days', A.block_timestamp, CURRENT_TIMESTAMP)) AS days_since_last_txn,

 SUM( CASE 
    WHEN B.action_name = 'Transfer' THEN 0
    WHEN B.action_data:method_name ilike 'transfer%' THEN 0
    WHEN A.block_timestamp < (current_date - 90) THEN 0
    ELSE 1 END
) AS n_complex_txn,

 count( distinct CASE 
    WHEN B.action_name = 'Transfer' THEN NULL
    WHEN B.action_data:method_name ilike 'transfer%' THEN NULL
    WHEN A.block_timestamp < (current_date - 90) THEN NULL
    WHEN A.TX_SIGNER = A.TX_RECEIVER THEN NULL
    ELSE A.TX_RECEIVER END
) as n_contracts

from near.core.fact_transactions A
left join near.core.fact_actions_events B
on A.tx_hash = B.tx_hash
group by 1

