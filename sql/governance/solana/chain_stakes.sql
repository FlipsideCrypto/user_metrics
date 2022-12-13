WITH hourly_price AS (
    SELECT recorded_hour AS hour
    , AVG(close) AS price
    FROM solana.core.fact_token_prices_hourly
    WHERE symbol = 'SOL'
        AND provider = 'coingecko'
    GROUP BY 1
), daily_price AS (
    SELECT recorded_hour::date AS date
    , AVG(close) AS price
    FROM solana.core.fact_token_prices_hourly
    WHERE symbol = 'SOL'
        AND provider = 'coingecko'
    GROUP BY 1
)
SELECT COALESCE(stake_authority, withdraw_authority) AS user_address
, 'Stake Program' AS protocol
, 'Stake11111111111111111111111111111111111111' AS token_contract
, 'SOL' AS token_symbol
, SUM(CASE WHEN post_tx_staked_balance > pre_tx_staked_balance THEN 1 ELSE 0 END) AS n_stakes
, SUM(CASE WHEN post_tx_staked_balance < pre_tx_staked_balance THEN 1 ELSE 0 END) AS n_unstakes
, SUM(CASE WHEN post_tx_staked_balance > pre_tx_staked_balance THEN (post_tx_staked_balance - pre_tx_staked_balance) * POWER(10, -9) ELSE 0 END) AS stake_token_volume
, SUM(CASE WHEN post_tx_staked_balance > pre_tx_staked_balance THEN COALESCE(h.price, d.price) * (post_tx_staked_balance - pre_tx_staked_balance) * POWER(10, -9) ELSE 0 END) AS stake_usd_volume
, SUM(CASE WHEN post_tx_staked_balance < pre_tx_staked_balance THEN (pre_tx_staked_balance - post_tx_staked_balance) * POWER(10, -9) ELSE 0 END) AS unstake_token_volume
, SUM(CASE WHEN post_tx_staked_balance < pre_tx_staked_balance THEN COALESCE(h.price, d.price) * (pre_tx_staked_balance - post_tx_staked_balance) * POWER(10, -9) ELSE 0 END) AS unstake_usd_volume
FROM solana.core.ez_staking_lp_actions l
LEFT JOIN hourly_price h
    ON h.hour = date_trunc('hour', l.block_timestamp)
LEFT JOIN daily_price d
    ON d.date = l.block_timestamp::date
WHERE block_timestamp >= CURRENT_DATE - {{metric_days}}
GROUP BY 1, 2, 3, 4