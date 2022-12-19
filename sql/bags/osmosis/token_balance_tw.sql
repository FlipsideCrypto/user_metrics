WITH base AS (
    SELECT
        b.date AS DATE,
        b.address AS user_address,
        b.currency AS token_contract,
        t.project_name AS token_symbol,
        SUM(balance / POW(10, b.decimal)) AS token_balance
    FROM
        osmosis.core.fact_daily_balances b
        INNER JOIN osmosis.core.dim_tokens t
        ON b.currency = t.address
    WHERE
        DATE >= CURRENT_DATE - 90
    GROUP BY
        DATE,
        user_address,
        token_contract,
        token_symbol
)
SELECT
    DATE,
    user_address,
    token_contract,
    token_symbol,
    AVG(token_balance) OVER (
        ORDER BY
            DATE ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
    ) AS token_balance_tw
FROM
    base
