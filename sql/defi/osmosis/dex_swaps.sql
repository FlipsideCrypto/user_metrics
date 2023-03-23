WITH trades_in AS (
  SELECT
    trader AS user_address,
    'osmosis' AS protocol,
    from_currency AS token_contract,
    project_name AS token_symbol,
    COUNT(*) AS n_sells,
    SUM(from_amount / POW(10, from_decimal)) AS sell_token_volume,
    SUM((from_amount / POW(10, from_decimal)) * price) AS sell_usd_volume
  FROM
    osmosis.core.fact_swaps s
    INNER JOIN osmosis.core.dim_tokens t
    ON from_currency = t.address
    INNER JOIN osmosis.core.dim_prices p
    ON DATE_TRUNC(
      'hour',
      s.block_timestamp
    ) = p.recorded_at
    AND t.project_name = p.symbol
  WHERE
    s.block_timestamp :: DATE >= CURRENT_DATE - 90
  GROUP BY
    user_address,
    protocol,
    token_contract,
    t.project_name,
    p.symbol
),
trades_out AS (
  SELECT
    trader AS user_address,
    'osmosis' AS protocol,
    to_currency AS token_contract,
    project_name AS token_symbol,
    COUNT(*) AS n_buys,
    SUM(to_amount / POW(10, TO_DECIMAL)) AS buy_token_volume,
    SUM((to_amount / POW(10, to_decimal)) * price) AS buy_usd_volume
  FROM
    osmosis.core.fact_swaps s
    INNER JOIN osmosis.core.dim_tokens t
    ON from_currency = t.address
    INNER JOIN osmosis.core.dim_prices p
    ON DATE_TRUNC(
      'hour',
      s.block_timestamp
    ) = p.recorded_at
    AND t.project_name = p.symbol
  WHERE
    s.block_timestamp :: DATE >= CURRENT_DATE - 90
  GROUP BY
    user_address,
    protocol,
    token_contract,
    t.project_name,
    p.symbol
)
SELECT
  user_address,
  protocol,
  token_contract,
  token_symbol,
  n_buys,
  n_sells,
  buy_token_volume,
  buy_usd_volume,
  sell_token_volume,
  sell_usd_volume
FROM
  trades_in NATURAL FULL
  JOIN trades_out
