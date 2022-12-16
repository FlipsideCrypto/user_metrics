WITH best_price AS (
  SELECT
    block_hour,
    asset_id,
    price_usd
  FROM
    (
      SELECT
        recorded_hour AS block_hour,
        asset_id,
        CLOSE AS price_usd,
        1 AS xrank
      FROM
        algorand.defi.ez_price_third_party_hourly
      UNION ALL
      SELECT
        block_hour,
        asset_id,
        price_usd,
        2 AS xrank
      FROM
        algorand.defi.ez_price_pool_balances
      UNION ALL
      SELECT
        block_hour,
        asset_id,
        price_usd,
        2 AS xrank
      FROM
        algorand.defi.ez_price_swap
    )
  WHERE
    block_hour >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE()) qualify(ROW_NUMBER() over(PARTITION BY block_hour, asset_id
  ORDER BY
    xrank) = 1)
),
cex AS (
  SELECT
    address,
    label AS exchange
  FROM
    algorand.core.dim_label
  WHERE
    label_type = 'cex'
),
dep AS (
  SELECT
    asset_sender AS user_address,
    b.exchange,
    A.asset_id :: STRING AS token_contract,
    A.asset_name AS token_symbol,
    COUNT(1) AS n_deposits,
    SUM(amount) AS dep_token_volume,
    SUM(amount * COALESCE(price_usd, 0)) AS dep_usd_volume
  FROM
    algorand.core.ez_transfer A
    JOIN cex b
    ON A.receiver = b.address
    LEFT JOIN best_price C
    ON A.asset_id = C.asset_ID
    AND DATE_TRUNC(
      'hour',
      A.block_timestamp
    ) = C.block_hour
  WHERE
    block_timestamp >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE())
  GROUP BY
    user_address,
    exchange,
    token_contract,
    token_symbol),
    wdraw AS (
      SELECT
        asset_sender AS user_address,
        b.exchange,
        A.asset_id :: STRING AS token_contract,
        A.asset_name AS token_symbol,
        COUNT(1) AS n_withdrawals,
        SUM(amount) AS wdraw_token_volume,
        SUM(amount * COALESCE(price_usd, 0)) AS wdraw_usd_volume
      FROM
        algorand.core.ez_transfer A
        JOIN cex b
        ON A.asset_sender = b.address
        LEFT JOIN best_price C
        ON A.asset_id = C.asset_ID
        AND DATE_TRUNC(
          'hour',
          A.block_timestamp
        ) = C.block_hour
      WHERE
        block_timestamp >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE())
      GROUP BY
        user_address,
        exchange,
        token_contract,
        token_symbol)
      SELECT
        x.user_address,
        x.exchange,
        x.token_contract,
        x.token_symbol,
        n_deposits,
        n_withdrawals,
        dep_token_volume,
        dep_usd_volume,
        wdraw_token_volume,
        wdraw_usd_volume
      FROM
        (
          SELECT
            DISTINCT user_address,
            exchange,
            token_contract,
            token_symbol
          FROM
            dep
          UNION
          SELECT
            DISTINCT user_address,
            exchange,
            token_contract,
            token_symbol
          FROM
            wdraw
        ) x
        LEFT JOIN dep A
        ON A.user_address = x.user_address
        AND A.exchange = x.exchange
        AND A.token_contract = x.token_contract
        LEFT JOIN wdraw b
        ON x.user_address = b.user_address
        AND x.exchange = b.exchange
        AND x.token_contract = b.token_contract
