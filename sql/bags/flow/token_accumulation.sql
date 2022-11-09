--user_address | token_contract | token_symbol | n_xfer_in | n_xfer_out | xfer_in_token_volume | xfer_in_usd_volume | xfer_out_token_volume | xfer_out_usd_volume
-- transfers + nft trades + dex swaps + bridge

--user_address | token_contract | token_symbol | n_xfer_in | n_xfer_out | xfer_in_token_volume | xfer_in_usd_volume | xfer_out_token_volume | xfer_out_usd_volume
-- transfers + nft trades + dex swaps + bridge

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

xfers_in AS (
  SELECT
  recipient AS user_addressa,
  symbol AS token_symbola,
  tt.token_contract AS token_contracta,
  count(tx_id) AS n_xfer_in,
  sum(amount) AS token_in_volume,
  sum(amount * price) AS usd_in_volume
  FROM FLOW.CORE.EZ_TOKEN_TRANSFERS tt
  JOIN daily_prices dp ON date_trunc('day', tt.block_timestamp) = dp.day
      AND tt.token_contract = dp.token_contract
  WHERE 
  block_timestamp >= current_date - 180
  AND
  tx_succeeded = TRUE
  AND 
  recipient NOT IN (SELECT account_address FROM FLOW.CORE.DIM_CONTRACT_LABELS)
  AND
  recipient NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow')
  AND
  amount != 0.001
  AND
  amount != 0.0001
  GROUP BY user_addressa, symbol, tt.token_contract
),

dex_buys AS (
  SELECT
  trader AS user_addressa,
  symbol AS token_symbola,
  token_in_contract AS token_contracta,
  count(tx_id) AS n_xfer_in,
  sum(token_in_amount) AS token_in_volume,
  sum(token_in_amount * price) AS usd_in_volume
  FROM
  flow.core.ez_dex_swaps ds
  JOIN daily_prices dp ON date_trunc('day', ds.block_timestamp) = dp.day
      AND ds.token_in_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  trader, symbol, token_in_contract
),

nft_sells AS (
 SELECT
  seller AS user_addressa,
  COALESCE(dp.symbol, SPLIT_PART(currency, '.', 2)) AS token_symbola,
  currency AS token_contracta,
  count(tx_id) AS n_xfer_in,
  sum(ns.price) AS token_in_volume,
  CASE 
    WHEN currency IN (select currency FROM missing_prices)
    THEN sum(ns.price * 1)
    ELSE sum(ns.price * dp.price)
  END  AS usd_in_volume
  FROM
  flow.core.ez_nft_sales ns
  JOIN daily_prices dp ON date_trunc('day', ns.block_timestamp) = dp.day
      AND ns.currency = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  seller, token_symbola, currency
),

bridge_in AS (
SELECT
  flow_wallet_address AS user_addressa,
  symbol AS token_symbola,
  bt.token_contract AS token_contracta,
  count(tx_id) AS n_xfer_in,
  sum(amount) AS token_in_volume,
  sum(amount * price) AS usd_in_volume
  FROM
  flow.core.fact_bridge_transactions bt
  JOIN daily_prices dp ON date_trunc('day', bt.block_timestamp) = dp.day
    AND bt.token_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  AND 
  direction = 'inbound'
  AND
  tx_id NOT IN (SELECT tx_id FROM flow.core.fact_bridge_transactions WHERE block_timestamp > current_date - 180)
  GROUP BY 
  user_addressa, symbol, bt.token_contract
),
all_ins AS (
SELECT * FROM xfers_in
UNION
SELECT * FROM dex_buys
UNION
SELECT * FROM nft_sells
UNION
SELECT * FROM bridge_in
),


xfers_out AS (
  SELECT
  sender AS user_addressa,
  symbol AS token_symbola,
  tt.token_contract AS token_contracta,
  count(tx_id) AS n_xfer_out,
  sum(amount) AS token_out_volume,
  sum(amount * price) AS usd_out_volume
  FROM FLOW.CORE.EZ_TOKEN_TRANSFERS tt
  JOIN daily_prices dp ON date_trunc('day', tt.block_timestamp) = dp.day
      AND tt.token_contract = dp.token_contract
  WHERE 
  block_timestamp >= current_date - 180
  AND
  tx_succeeded = TRUE
  AND 
  recipient NOT IN (SELECT account_address FROM FLOW.CORE.DIM_CONTRACT_LABELS)
  AND
  recipient NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow')
  GROUP BY user_addressa, symbol, tt.token_contract
),

dex_sells AS (
  SELECT
  trader AS user_addressa,
  symbol AS token_symbola,
  token_out_contract AS token_contracta,
  count(tx_id) AS n_xfer_out,
  sum(token_in_amount) AS token_out_volume,
  sum(token_in_amount * price) AS usd_out_volume
  FROM
  flow.core.ez_dex_swaps ds
  JOIN daily_prices dp ON date_trunc('day', ds.block_timestamp) = dp.day
      AND ds.token_out_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  trader, symbol, token_out_contract
),

nft_buys AS (
 SELECT
  buyer AS user_addressa,
  COALESCE(dp.symbol, SPLIT_PART(currency, '.', 2)) AS token_symbola,
  currency AS token_contracta,
  count(tx_id) AS n_xfer_out,
  sum(ns.price) AS token_out_volume,
  CASE 
    WHEN currency IN (select currency FROM missing_prices)
    THEN sum(ns.price * 1)
    ELSE sum(ns.price * dp.price)
  END  AS usd_out_volume
  FROM
  flow.core.ez_nft_sales ns
  JOIN daily_prices dp ON date_trunc('day', ns.block_timestamp) = dp.day
      AND ns.currency = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  GROUP BY 
  buyer, token_symbola, currency
),

bridge_out AS (
SELECT
  flow_wallet_address AS user_addressa,
  symbol AS token_symbola,
  bt.token_contract AS token_contracta,
  count(tx_id) AS n_xfer_out,
  sum(amount) AS token_out_volume,
  sum(amount * price) AS usd_out_volume
  FROM
  flow.core.fact_bridge_transactions bt
  JOIN daily_prices dp ON date_trunc('day', bt.block_timestamp) = dp.day
    AND bt.token_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 180
  AND 
  direction = 'outbound'
  AND
  tx_id NOT IN (SELECT tx_id FROM flow.core.fact_bridge_transactions WHERE block_timestamp > current_date - 180)
  GROUP BY 
  user_addressa, symbol, bt.token_contract
),
all_outs AS (
SELECT * FROM xfers_out
UNION
SELECT * FROM dex_sells
UNION
SELECT * FROM nft_buys
UNION
SELECT * FROM bridge_out
)

SELECT
coalesce(ai.user_addressa, ao.user_addressa) AS user_address,
coalesce(ai.token_symbola, ao.token_symbola) AS token_symbol,
coalesce(ai.token_contracta, ao.token_contracta) AS token_contract,

sum(coalesce(n_xfer_in, 0)) AS n_xfer_in,
sum(coalesce(token_in_volume, 0)) AS token_in_volume,
sum(coalesce(usd_in_volume, 0)) AS usd_in_volume,

sum(coalesce(n_xfer_out, 0)) AS n_xfer_out,
sum(coalesce(token_out_volume, 0)) AS token_out_volume,
sum(coalesce(usd_out_volume, 0)) AS usd_out_volume
  
FROM all_ins ai
FULL OUTER JOIN all_outs ao ON ai.user_addressa = ao.user_addressa
AND ai.token_symbola = ao.token_symbola
AND ai.token_contracta = ao.token_contracta

GROUP BY
user_address, token_symbol, token_contract

