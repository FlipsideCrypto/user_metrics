WITH delegates AS (
    SELECT
        delegator_address AS user_address,
        'axelar' AS protocol,
        currency AS token_contract,
        t.project_name AS token_symbol,
        COUNT(*) AS n_stakes,
        SUM(amount / POW(10, 6)) AS stake_token_volume,
        SUM((amount / POW(10, 6)) * price) AS stake_usd_volume
    FROM
        axelar.core.fact_staking s
        INNER JOIN axelar.core.dim_tokens t
        ON s.currency = t.alias
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
        'axelar' AS protocol,
        currency AS token_contract,
        t.project_name AS token_symbol,
        COUNT(*) AS n_unstakes,
        SUM(amount / POW(10, 6)) AS unstake_token_volume,
        SUM((amount / POW(10, 6)) * price) AS unstake_usd_volume
    FROM
        axelar.core.fact_staking s
        INNER JOIN axelar.core.dim_tokens t
        ON s.currency = t.alias
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