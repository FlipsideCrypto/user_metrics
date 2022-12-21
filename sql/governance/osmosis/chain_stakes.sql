WITH delegates AS (
    SELECT
        delegator_address AS user_address,
        'osmosis' AS protocol,
        currency AS token_contract,
        t.project_name AS token_symbol,
        COUNT(*) AS n_stakes,
        SUM(amount / POW(10, s.decimal)) AS stake_token_volume,
        SUM((amount / POW(10, s.decimal)) * price) AS stake_usd_volume
    FROM
        osmosis.core.fact_staking s
        INNER JOIN osmosis.core.dim_tokens t
        ON s.currency = t.address
        INNER JOIN osmosis.core.dim_prices p
        ON DATE_TRUNC(
            'hour',
            s.block_timestamp
        ) = p.recorded_at
        AND t.project_name = p.symbol
    WHERE
        s.block_timestamp :: DATE >= CURRENT_DATE - 90
        AND action = 'delegate'
    GROUP BY
        delegator_address,
        protocol,
        currency,
        token_symbol
),
undelegates AS (
    SELECT
        delegator_address AS user_address,
        'osmosis' AS protocol,
        currency AS token_contract,
        t.project_name AS token_symbol,
        COUNT(*) AS n_unstakes,
        SUM(amount / POW(10, s.decimal)) AS unstake_token_volume,
        SUM((amount / POW(10, s.decimal)) * price) AS unstake_usd_volume
    FROM
        osmosis.core.fact_staking s
        INNER JOIN osmosis.core.dim_tokens t
        ON s.currency = t.address
        INNER JOIN osmosis.core.dim_prices p
        ON DATE_TRUNC(
            'hour',
            s.block_timestamp
        ) = p.recorded_at
        AND t.project_name = p.symbol
    WHERE
        s.block_timestamp :: DATE >= CURRENT_DATE - 90
        AND action = 'undelegate'
    GROUP BY
        delegator_address,
        protocol,
        currency,
        token_symbol
)
SELECT
    user_address,
    protocol,
    token_contract,
    token_symbol,
    n_stakes,
    n_unstakes,
    stake_token_volume,
    stake_usd_volume,
    unstake_usd_volume unstake_token_volume,
    unstake_usd_volume
FROM
    delegates NATURAL FULL
    JOIN undelegates
