WITH ins AS (
    SELECT
        sender,
        receiver,
        foreign_address,
        foreign_chain, 
        'IBC' AS bridge_name,
        currency AS token_contract,
        t.project_name AS token_symbol,
        COUNT(*) AS n_in,
        SUM(amount / POW(10, l.decimal)) AS in_token_volume,
        SUM((amount / POW(10, l.decimal)) * price) AS in_usd_volume
    FROM
        osmosis.core.fact_transfers l
        INNER JOIN osmosis.core.dim_tokens t
        ON l.currency = t.address
        INNER JOIN osmosis.core.dim_prices p
        ON DATE_TRUNC(
            'hour',
            l.block_timestamp
        ) = p.recorded_at
        AND t.project_name = p.symbol
    WHERE
        block_timestamp :: DATE >= CURRENT_DATE - 90
        AND transfer_type = 'IBC_TRANSFER_IN'
    GROUP BY
        user_address,
        bridge_name,
        token_contract,
        token_symbol
),
outs AS (
    SELECT
        sender,
        receiver,
        foreign_address,
        foreign_chain, 
        'IBC' AS bridge_name,
        currency AS token_contract,
        t.project_name AS token_symbol,
        COUNT(*) AS n_out,
        SUM(amount / POW(10, l.decimal)) AS out_token_volume,
        SUM((amount / POW(10, l.decimal)) * price) AS out_usd_volume
    FROM
        osmosis.core.fact_transfers l
        INNER JOIN osmosis.core.dim_tokens t
        ON l.currency = t.address
        INNER JOIN osmosis.core.dim_prices p
        ON DATE_TRUNC(
            'hour',
            l.block_timestamp
        ) = p.recorded_at
        AND t.project_name = p.symbol
    WHERE
        block_timestamp :: DATE >= CURRENT_DATE - 90
        AND transfer_type = 'IBC_TRANSFER_OUT'
    GROUP BY
        user_address,
        bridge_name,
        token_contract,
        token_symbol
)
SELECT
    user_address,
    bridge_name,
    token_contract,
    token_symbol,
    n_in,
    n_out,
    in_token_volume,
    in_usd_volume,
    out_token_volume,
    out_usd_volume
FROM
    ins NATURAL FULL
    JOIN outs