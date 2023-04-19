WITH deps AS (
  SELECT
    liquidity_provider_address AS user_address,
    'osmosis' AS protocol,
    COUNT(*) AS n_deposits,
    SUM((amount / POW(10, l.decimal)) * price) AS dep_usd_volume
  FROM
    osmosis.core.fact_liquidity_provider_actions l
    INNER JOIN osmosis.core.dim_tokens t
    ON l.currency = t.address
    INNER JOIN osmosis.core.dim_prices p
    ON DATE_TRUNC(
      'hour',
      l.block_timestamp
    ) = p.recorded_at
    AND t.project_name = p.symbol
  WHERE
     pool_id[0] IN (
        SELECT pool_id 
        FROM osmosis.core.dim_liquidity_pools 
        WHERE assets[0] :asset_address = 'ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E'
        OR assets[1] :asset_address = 'ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E'
    )
    AND action = 'pool_joined'
    AND l.block_timestamp >= CURRENT_DATE - 90
  GROUP BY
    liquidity_provider_address,
    protocol
),
withdraw AS (
  SELECT
    liquidity_provider_address AS user_address,
    'osmosis' AS protocol,
    COUNT(*) AS n_withdrawals,
    SUM((amount / POW(10, l.decimal)) * price) AS wdraw_usd_volume
  FROM
    osmosis.core.fact_liquidity_provider_actions l
    INNER JOIN osmosis.core.dim_tokens t
    ON l.currency = t.address
    INNER JOIN osmosis.core.dim_prices p
    ON DATE_TRUNC(
      'hour',
      l.block_timestamp
    ) = p.recorded_at
    AND t.project_name = p.symbol
  WHERE
    pool_id[0] IN (
        SELECT pool_id 
        FROM osmosis.core.dim_liquidity_pools 
        WHERE assets[0] :asset_address = 'ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E'
        OR assets[1] :asset_address = 'ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E'
    )
    AND action = 'pool_exited'
    AND l.block_timestamp >= CURRENT_DATE - 90
  GROUP BY
    liquidity_provider_address,
    protocol
)
SELECT
  user_address,
  protocol,
  n_deposits,
  n_withdrawals,
  dep_usd_volume,
  wdraw_usd_volume
FROM
  deps NATURAL FULL
  JOIN withdraw