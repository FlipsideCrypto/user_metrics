WITH format_delegations AS (
select
*,
(raw_new_balance - raw_previous_balance) / pow(10, 18) AS net_delegation
FROM optimism.core.fact_delegations
where delegation_type != 'Re-Delegation'
AND
block_timestamp > current_date - 180
)
SELECT
delegator AS user_address,
'0x4200000000000000000000000000000000000042' AS token_contract,
'OP' AS token_symbol,
count(distinct(tx_hash)) AS n_stakes,
0 AS n_unstakes,
sum(net_delegation) AS stake_token_volume,
0 AS stake_usd_volume,
0 AS unstake_token_volume,
0 AS unstake_usd_volume
FROM format_delegations
WHERE
delegator NOT IN (SELECT address FROM crosschain.core.ADDRESS_LABELS where blockchain = 'optimism')
GROUP BY 
delegator
