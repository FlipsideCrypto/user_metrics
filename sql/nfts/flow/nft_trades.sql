WITH daily_prices AS (
SELECT 
  symbol,
  token_contract,
  date_trunc('day', timestamp) AS day,
  AVG(price_usd) AS price
FROM flow.core.fact_prices
  --WHERE token_contract = 'A.16546533918040a61.FlowToken'
WHERE timestamp > current_date - 91
GROUP BY symbol, token_contract, day
),
missing_prices AS (
  SELECT currency FROM "FLOW"."CORE"."EZ_NFT_SALES" WHERE currency NOT IN (select token_contract from "FLOW"."CORE"."FACT_PRICES") group by currency
),
sells AS (
  SELECT
  seller AS user_address,
  marketplace,
  nft_collection AS nf_token_contract,
  count(distinct(nft_id)) AS n_nfts_sold,
  COALESCE(dp.symbol, SPLIT_PART(currency, '.', 2)) AS sell_symbol,
  currency,
  count(tx_id) AS n_sells,
  sum(ns.price) AS token_sell_volume,
  CASE 
    WHEN currency IN (select currency FROM missing_prices)
    THEN sum(ns.price * 1)
    ELSE sum(ns.price * dp.price)
  END  AS sell_usd_volume
  FROM
  flow.core.ez_nft_sales ns
  LEFT JOIN daily_prices dp ON date_trunc('day', ns.block_timestamp) = dp.day
      AND ns.currency = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  seller, marketplace, nf_token_contract, sell_symbol, currency
),
buys AS (
  SELECT
  buyer AS user_address,
  marketplace,
  nft_collection AS nf_token_contract,
  count(distinct(nft_id)) AS n_nfts_bought,
  COALESCE(dp.symbol, SPLIT_PART(currency, '.', 2)) AS buy_symbol,
  currency,
  count(tx_id) AS n_buys,
  sum(ns.price) AS token_buy_volume,
  CASE 
    WHEN currency IN (select currency FROM missing_prices)
    THEN sum(ns.price * 1)
    ELSE sum(ns.price * dp.price)
  END  AS buy_usd_volume
  FROM
  flow.core.ez_nft_sales ns
  LEFT JOIN daily_prices dp ON date_trunc('day', ns.block_timestamp) = dp.day
      AND ns.currency = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  buyer, marketplace, nf_token_contract, buy_symbol, currency
)

SELECT
COALESCE(sells.user_address, buys.user_address) AS user_address,
COALESCE(sells.marketplace, buys.marketplace) AS marketplace,
COALESCE(sells.nf_token_contract, buys.nf_token_contract) AS nf_token_contract,
COALESCE(buys.n_nfts_bought, 0) AS n_nfts_bought,
COALESCE(sells.n_nfts_sold, 0) AS n_nfts_sold,
SPLIT_PART(COALESCE(sells.nf_token_contract, buys.nf_token_contract), '.', 2) AS nft_project,
COALESCE(sells.currency, buys.currency) AS token_contract,
COALESCE(sells.sell_symbol, buys.buy_symbol) AS token_symbol,
COALESCE(n_buys, 0) AS n_buys,
COALESCE(token_buy_volume, 0) AS buy_token_volume,
COALESCE(buy_usd_volume, 0) AS buy_usd_volume,
COALESCE(n_sells, 0) AS n_sells,
COALESCE(token_sell_volume, 0) AS sell_token_volume,
COALESCE(sell_usd_volume, 0) AS sell_usd_volume
FROM sells
FULL OUTER JOIN buys ON sells.user_address = buys.user_address
AND sells.marketplace = buys.marketplace
AND sells.nf_token_contract = buys.nf_token_contract
AND sells.currency = buys.currency






