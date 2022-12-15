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
    block_hour >= DATEADD('day',- {{ last_n_days }} + 1, CURRENT_DATE()) qualify(ROW_NUMBER() over(PARTITION BY block_hour, asset_id
  ORDER BY
    xrank) = 1)
),
trades_in AS (
  SELECT
    dim_account_id__swapper AS user_address,
    swap_program AS protocol,
    swap_from_asset_id AS token_contract,
    COUNT(*) AS n_sells,
    SUM(swap_from_amount) AS sell_token_volume,
    SUM(swap_from_amount * COALESCE(price_usd, 0)) AS sell_usd_volume
  FROM
    algorand.defi.fact_swap A
    JOIN algorand.core.dim_asset b
    ON A.swap_from_asset_ID = b.asset_id
    LEFT JOIN best_price C
    ON A.swap_from_asset_id = C.asset_ID
    AND DATE_TRUNC(
      'hour',
      A.block_timestamp
    ) = C.block_hour
  WHERE
    block_timestamp >= DATEADD('day',- {{ last_n_days }}, CURRENT_DATE())
  GROUP BY
    user_address,
    protocol,
    token_contract),
    trades_out AS (
      SELECT
        dim_account_id__swapper AS user_address,
        swap_program AS protocol,
        swap_to_asset_id AS token_contract,
        COUNT(*) AS n_buys,
        SUM(swap_to_amount) AS buy_token_volume,
        SUM(swap_from_amount * COALESCE(price_usd, 0)) AS buy_usd_volume
      FROM
        algorand.defi.fact_swap A
        JOIN algorand.core.dim_asset b
        ON A.swap_to_asset_ID = b.asset_id
        LEFT JOIN best_price C
        ON A.swap_from_asset_id = C.asset_ID
        AND DATE_TRUNC(
          'hour',
          A.block_timestamp
        ) = C.block_hour
      WHERE
        block_timestamp >= DATEADD('day',- {{ last_n_days }}, CURRENT_DATE())
      GROUP BY
        user_address,
        protocol,
        token_contract),
        FINAL AS (
          SELECT
            x.user_address,
            x.protocol,
            x.token_contract,
            n_buys,
            n_sells,
            buy_token_volume,
            buy_usd_volume,
            sell_token_volume,
            sell_usd_volume
          FROM
            (
              SELECT
                DISTINCT user_address,
                protocol,
                token_contract
              FROM
                trades_in
              UNION
              SELECT
                DISTINCT user_address,
                protocol,
                token_contract
              FROM
                trades_out
            ) x
            LEFT JOIN trades_in A
            ON A.user_address = x.user_address
            AND A.protocol = x.protocol
            AND A.token_contract = x.token_contract
            LEFT JOIN trades_out b
            ON x.user_address = b.user_address
            AND x.protocol = b.protocol
            AND x.token_contract = b.token_contract
        )
      SELECT
        b.address AS user_address,
        protocol,
        token_contract :: STRING AS token_contract,
        C.asset_name AS token_symbol,
        n_buys,
        n_sells,
        buy_token_volume,
        buy_usd_volume,
        sell_token_volume,
        sell_usd_volume
      FROM
        FINAL A
        JOIN algorand.core.dim_account b
        ON A.user_address = b.dim_account_id
        JOIN algorand.core.dim_asset C
        ON A.token_contract = C.asset_id
