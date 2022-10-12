WITH sells AS (
  SELECT
  seller AS user_address,
  marketplace,
  nft_collection AS nf_token_contract,
  count(tx_id) AS n_sells,
  sum(price) AS token_sell_volume,
  currency
  FROM
  flow.core.ez_nft_sales
  WHERE
  block_timestamp > current_date - 90
  GROUP BY 
  seller, marketplace, nf_token_contract, currency
),

buys AS (
  SELECT
  buyer AS user_address,
  marketplace,
  nft_collection AS nf_token_contract,
  count(tx_id) AS n_buys,
  sum(price) AS token_buy_volume,
  currency
  FROM
  flow.core.ez_nft_sales
  WHERE
  block_timestamp > current_date - 90
  GROUP BY 
  buyer, marketplace, nf_token_contract, currency
)

SELECT
COALESCE(sells.user_address, buys.user_address) AS user_address,
COALESCE(sells.marketplace, buys.marketplace) AS marketplace,
COALESCE(sells.nf_token_contract, buys.nf_token_contract) AS nf_token_contract,
'tbd' AS nft_project,
COALESCE(sells.currency, buys.currency) AS token_contract,
'tbd' AS token_symbol,
COALESCE(n_buys, 0) AS n_buys,
COALESCE(token_buy_volume, 0) AS buy_token_volume,
0 AS buy_usd_volume,
COALESCE(n_sells, 0) AS n_sells,
COALESCE(token_sell_volume, 0) AS sell_token_volume,
0 AS sell_usd_volume,
FROM sells
FULL OUTER JOIN buys ON sells.user_address = buys.user_address
AND sells.marketplace = buys.marketplace
AND sells.nf_token_contract = buys.nf_token_contract
AND sells.currency = buys.currency