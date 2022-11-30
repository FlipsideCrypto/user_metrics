-- user_address | marketplace | nf_token_contract | nft_project |  n_buys | buy_usd_volume | n_sells | sell_usd_volume

 
with sales AS (
SELECT SELLER_ADDRESS as user_address, platform_name as marketplace, NFT_ADDRESS as nf_token_contract, PROJECT_NAME as nft_project, 
  COUNT(*) as n_sells, SUM(PRICE_USD) as sell_usd_volume
FROM ethereum.core.ez_nft_sales
WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
  CURRENT_DATE())
  GROUP BY user_address, marketplace, nf_token_contract, nft_project
), 

buys AS (
SELECT BUYER_ADDRESS as user_address, platform_name as marketplace, NFT_ADDRESS as nf_token_contract, PROJECT_NAME as nft_project, 
  COUNT(*) as n_buys, SUM(PRICE_USD) as buy_usd_volume
FROM ethereum.core.ez_nft_sales
WHERE BLOCK_TIMESTAMP >= DATEADD('day',
-- Last N Days parameter, default -1000
-- -{{last_n_days}},
-1000, 
  CURRENT_DATE())
  GROUP BY user_address, marketplace, nf_token_contract, nft_project
)

SELECT user_address, marketplace, nf_token_contract, nft_project,  n_buys, buy_usd_volume, n_sells, sell_usd_volume
FROM sales NATURAL FULL OUTER JOIN buys 