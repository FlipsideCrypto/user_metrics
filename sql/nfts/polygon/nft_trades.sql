WITH sells AS (
  SELECT
  seller_address AS user_address,
  platform_name AS marketplace,
  nft_address AS nf_token_contract,
  count(distinct(tokenid)) AS n_nfts_sold,
  currency_symbol AS sell_symbol,
  currency_address AS currency,
  count(tx_hash) AS n_sells,
  sum(price) AS token_sell_volume,
  sum(price_usd) AS sell_usd_volume
  FROM
  polygon.core.ez_nft_sales ns
  WHERE
  block_timestamp > current_date - 180
  AND
  user_address NOT IN (SELECT address FROM crosschain.core.ADDRESS_LABELS where blockchain = 'optimism')
  GROUP BY 
  seller_address, marketplace, nf_token_contract, sell_symbol, currency
),
buys AS (
  SELECT
  buyer_address AS user_address,
  platform_name AS marketplace,
  nft_address AS nf_token_contract,
  count(distinct(tokenid)) AS n_nfts_bought,
  currency_symbol AS buy_symbol,
  currency_address AS currency,
  count(tx_hash) AS n_buys,
  sum(price) AS token_buy_volume,
  sum(price_usd) AS buy_usd_volume
  FROM
  polygon.core.ez_nft_sales ns
  WHERE
  block_timestamp > current_date - 180
  AND
  user_address NOT IN (SELECT address FROM crosschain.core.ADDRESS_LABELS where blockchain = 'optimism')
  GROUP BY 
  buyer_address, marketplace, nf_token_contract, buy_symbol, currency
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

