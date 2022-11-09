WITH pools AS (
  select
  *
    from "FLOW"."CORE"."DIM_CONTRACT_LABELS"
  where contains(lower(contract_name), 'pair')
),
user_txn AS (SELECT
             tx_id,
             event_data:to::string AS user_address
             FROM "FLOW"."CORE"."FACT_EVENTS"
             WHERE
             event_contract IN (select event_contract FROM pools)
             AND
             event_data:to::string NOT IN (select account_address FROM pools)
             AND
             event_type = 'TokensDeposited'
             AND
             block_timestamp > current_date - 180
)
SELECT
fe.tx_id, event_data:amount AS token_value, event_contract, event_data:from::string AS user_address
FROM "FLOW"."CORE"."FACT_EVENTS" fe
JOIN user_txn ut ON fe.tx_id = ut.tx_id AND fe.event_data:from = ut.user_address
WHERE 
block_timestamp > current_date - 180
AND
event_type = 'TokensWithdrawn'
AND event_data:amount > 0