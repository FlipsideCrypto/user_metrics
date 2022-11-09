

--A.396c0cda3302d8c5.SwapPair

WITH stakes AS (
SELECT
event_data:operator::string AS user_address,
'increment' AS protocol,
event_data:tokenKey::string AS token_contract,
count(tx_id) AS n_stakes,
sum(event_data:amount::number) AS stake_token_volume

FROM FLOW.CORE.FACT_EVENTS 
where 
block_timestamp > current_date - 180
AND
event_contract = 'A.1b77ba4b414de352.Staking' 
AND 
event_type = 'TokenStaked'
  
GROUP BY user_address, protocol, token_contract
),

unstakes AS (
SELECT
event_data:operator::string AS user_address,
'increment' AS protocol,
event_data:tokenKey::string AS token_contract,
count(tx_id) AS n_unstakes,
sum(event_data:amount::number) AS unstake_token_volume
FROM FLOW.CORE.FACT_EVENTS 
where 
block_timestamp > current_date - 180
AND
event_contract = 'A.1b77ba4b414de352.Staking' 
AND 
event_type = 'TokenUnstaked'
GROUP BY user_address, protocol, token_contract
)

SELECT
COALESCE(unstakes.user_address, stakes.user_address) AS user_address,
COALESCE(unstakes.protocol, stakes.protocol) AS protocol,
COALESCE(unstakes.token_contract, stakes.token_contract) AS token_contract,
COALESCE(n_stakes, 0) AS n_stakes,
COALESCE(n_unstakes, 0) AS n_unstakes,
COALESCE(stake_token_volume, 0) AS stake_token_volume,
0 AS stake_usd_volume,
COALESCE(unstake_token_volume, 0) AS unstake_token_volume,
0 AS unstake_usd_volume

FROM unstakes
FULL OUTER JOIN stakes ON unstakes.user_address = stakes.user_address
AND unstakes.protocol = stakes.protocol
AND unstakes.token_contract = stakes.token_contract


