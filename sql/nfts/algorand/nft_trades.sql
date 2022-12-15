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
)
SELECT
  purchaser AS user_address,
  nft_marketplace AS marketplace,
  NULL AS nf_token_contract,
  COALESCE(
    collection_name,
    'unknown'
  ) AS nft_project,
  COUNT(1) AS n_buys,
  SUM(total_sales_amount * COALESCE(price_usd, 0)) AS buy_usd_volume,
  NULL AS n_sells,
  NULL AS sell_usd_volume
FROM
  algorand.nft.ez_nft_sales
  LEFT JOIN best_price C
  ON C.asset_ID = 0
  AND DATE_TRUNC(
    'hour',
    block_timestamp
  ) = C.block_hour
WHERE
  block_timestamp >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE())
GROUP BY
  user_address,
  marketplace,
  nft_project
UNION ALL
SELECT
  purchaser AS user_address,
  'fifa+ collect' AS marketplace,
  NULL AS nf_token_contract,
  'fifa+ collect' AS nft_project,
  COUNT(1) AS n_buys,
  SUM(total_sales_amount_usd) AS buy_usd_volume,
  NULL AS n_sells,
  NULL AS sell_usd_volume
FROM
  algorand.nft.ez_nft_sales_FIFA
WHERE
  block_timestamp >= DATEADD('day',- {{ metric_days }}, CURRENT_DATE())
GROUP BY
  user_address,
  marketplace,
  nft_project
