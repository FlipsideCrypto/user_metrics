SELECT
    b.address AS user_address,
    b.currency AS token_contract,
    t.project_name AS token_symbol,
    SUM(balance / POW(10, b.decimal)) AS token_balance
FROM
    osmosis.core.fact_daily_balances b
    INNER JOIN osmosis.core.dim_tokens t
    ON b.currency = t.address
WHERE
    DATE = CURRENT_DATE
GROUP BY
    user_address,
    token_contract,
    t.project_name
