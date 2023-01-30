WITH base AS (
    SELECT
        b.date AS DATE,
        b.address AS user_address,
        t.address AS token_contract,
        t.project_name AS token_symbol,
        SUM(balance / POW(10, t.decimal)) AS token_balance
    FROM
        axelar.core.fact_daily_balances b
        INNER JOIN axelar.core.dim_tokens t
        ON b.currency = t.alias
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