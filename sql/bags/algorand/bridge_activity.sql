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
outbound AS (
  SELECT
    bridger_address AS user_address,
    bridge AS bridge_name,
    A.asset_id AS token_contract,
    COUNT(*) AS n_outbound,
    SUM(amount) AS out_token_volume,
    SUM(amount * COALESCE(price_usd, 0)) AS out_usd_volume
  FROM
    algorand.defi.fact_bridge_actions A
    LEFT JOIN best_price C
    ON A.asset_id = C.asset_ID
    AND DATE_TRUNC(
      'hour',
      A.block_timestamp
    ) = C.block_hour
  WHERE
    direction = 'outbound'
    AND block_timestamp >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE())
  GROUP BY
    user_address,
    bridge_name,
    token_contract),
    inbound AS (
      SELECT
        bridger_address AS user_address,
        bridge AS bridge_name,
        A.asset_id AS token_contract,
        COUNT(*) AS n_inbound,
        SUM(amount) AS in_token_volume,
        SUM(amount * COALESCE(price_usd, 0)) AS in_usd_volume
      FROM
        algorand.defi.fact_bridge_actions A
        LEFT JOIN best_price C
        ON A.asset_id = C.asset_ID
        AND DATE_TRUNC(
          'hour',
          A.block_timestamp
        ) = C.block_hour
      WHERE
        direction = 'inbound'
        AND block_timestamp >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE())
      GROUP BY
        user_address,
        bridge_name,
        token_contract),
        FINAL AS (
          SELECT
            x.user_address,
            x.bridge_name,
            x.token_contract,
            n_outbound,
            n_inbound,
            out_token_volume,
            out_usd_volume,
            in_token_volume,
            in_usd_volume
          FROM
            (
              SELECT
                DISTINCT user_address,
                bridge_name,
                token_contract
              FROM
                outbound
              UNION
              SELECT
                DISTINCT user_address,
                bridge_name,
                token_contract
              FROM
                inbound
            ) x
            LEFT JOIN outbound A
            ON A.user_address = x.user_address
            AND A.bridge_name = x.bridge_name
            AND A.token_contract = x.token_contract
            LEFT JOIN inbound b
            ON x.user_address = b.user_address
            AND x.bridge_name = b.bridge_name
            AND x.token_contract = b.token_contract
        )
      SELECT
        A.user_address,
        bridge_name,
        token_contract :: STRING AS token_contract,
        C.asset_name AS token_symbol,
        n_inbound AS n_in,
        n_outbound AS n_out,
        in_token_volume,
        in_usd_volume,
        out_token_volume,
        out_usd_volume
      FROM
        FINAL A
        JOIN algorand.core.dim_asset C
        ON A.token_contract = C.asset_id
