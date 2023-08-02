library(shroomDK)
library(data.table)

# load his file for later
ReplaceValues <- function(table = dt,
                          from = NA,
                          to = 0,
                          columns = "all.vars"){
  if(columns[[1]] == "all.vars"){ 
    which.cols <- seq_len(ncol(table))
  } else {
    which.cols <- which(names(table) %in% columns)
  }
  
  if(is.na(from)){
    for (j in which.cols)
      set(table,which(is.na(table[[j]])),j,to)
  } else {
    for (j in which.cols)
      set(table,which(table[[j]] == from),j,to)
  }
}

# read api key (not in github get one here: https://sdk.flipsidecrypto.xyz/shroomdk)
api.key <- readLines("api_key.txt")

# load labels and contracts
flow.labels <- auto_paginate_query(query = "SELECT * FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS where blockchain = 'flow'",
                                      api_key = api.key)

flow.contracts <- auto_paginate_query(query = "SELECT * FROM flow.core.dim_contract_labels",
                                   api_key = api.key)


# load daper pack rips
pack.rips <- auto_paginate_query(query = "
with wdraws AS (
SELECT
tx_id, 
event_data:from::string AS xfer_from,
event_data:id::string AS nft_id
FROM
FLOW.CORE.fact_events
where 
block_timestamp > current_date - 90
AND
tx_id not in (SELECT tx_id from flow.core.ez_nft_sales)
AND
event_type = 'Withdraw'
AND
(

(event_data:from  = '0xe1f2a091f7bb5245' AND event_contract = 'A.0b2a3299cc857e29.TopShot')
OR
(event_data:from  IN ('0xe4cf4bdc1751c65d', '0x44c6a6fd2281b6cc') AND event_contract = 'A.e4cf4bdc1751c65d.AllDay')
OR
(event_data:from  IN ('0x87ca73a41bb50ad5', '0xb6f2481eba4df97b') AND event_contract = 'A.87ca73a41bb50ad5.Golazos')
OR
(event_data:from  = '0x329feb3ab062d289' AND event_contract =  'A.329feb3ab062d289.UFC_NFT')
)

)
  
SELECT
event_data:to::string AS user_address,
event_contract AS nft_collection,
count(distinct(fe.tx_id)) AS n_rips, 
count(distinct(event_data:id::string)) AS n_nft_ids_ripped
FROM
FLOW.CORE.fact_events fe
JOIN wdraws on fe.tx_id = wdraws.tx_id AND fe.event_data:id::string = wdraws.nft_id
WHERE
event_contract IN ('A.0b2a3299cc857e29.TopShot', 'A.e4cf4bdc1751c65d.AllDay', 'A.329feb3ab062d289.UFC_NFT', 'A.87ca73a41bb50ad5.Golazos')
AND
event_type = 'Deposit'
GROUP BY 
user_address, nft_collection",
api_key = api.key)


# listings
nft.listings <- auto_paginate_query(query = "
WITH listings AS (
  select
  event_data:seller::string AS user_address,
  count(tx_id) AS listings
  FROM flow.core.fact_events
  WHERE 
  event_contract IN ('A.c1e4f4f4c4257510.TopShotMarketV3', 'A.c38aea683c0c4d38.Market')
  AND 
  event_type = 'MomentListed'
  AND
  block_timestamp >= current_date - 180
  AND
  tx_succeeded = TRUE
  GROUP BY user_address
  
  UNION
  
  select
event_data:storefrontAddress::string AS user_address,
count(tx_id) AS listings
FROM flow.core.fact_events
WHERE 
event_contract IN ('A.4eb8a10cb9f87357.NFTStorefront', 'A.4eb8a10cb9f87357.NFTStorefrontV2')
AND 
event_type = 'ListingAvailable'
AND
block_timestamp >= current_date - 180
AND
tx_succeeded = TRUE
GROUP BY user_address

UNION

select
  event_data:seller::string AS user_address,
  count(tx_id) AS listings
  FROM flow.core.fact_events
  WHERE 
  event_contract = 'A.85b075e08d13f697.OlympicPinMarket'
  AND 
  event_type = 'PieceListed'
  AND
  block_timestamp >= current_date - 180
  AND
  tx_succeeded = TRUE
  GROUP BY user_address
  
)

SELECT
user_address,
sum(listings) AS n_listings
FROM
listings
WHERE
user_address NOT IN (SELECT account_address FROM FLOW.CORE.DIM_CONTRACT_LABELS)
AND
user_address NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow')
GROUP BY user_address
",
api_key = api.key)



nft.sales <- auto_paginate_query(query = "WITH daily_prices AS (
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
  SELECT currency FROM flow.core.ez_nft_sales WHERE currency NOT IN (select token_contract from flow.core.fact_prices) group by currency
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
  block_timestamp > current_date - 91
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
  block_timestamp > current_date - 91
  AND
  -- exclude pack sellers, allday and la liga
  seller NOT IN ('0xe4cf4bdc1751c65d', '0x87ca73a41bb50ad5')
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
AND sells.currency = buys.currency",
api_key = api.key)



# chain stakes (FLOW staking):
chain.stakes <- auto_paginate_query(query = "
WITH daily_prices AS (
  SELECT date_trunc('day', timestamp) AS day,
  AVG(price_usd) AS price
  FROM flow.core.fact_prices
  WHERE token_contract = 'A.1654653399040a61.FlowToken'
  GROUP BY day
),

stakes AS (
  SELECT
  delegator AS user_address,
  count(tx_id) AS n_stakes,
  sum(amount) AS stake_token_volume,
  sum(amount * price) AS stake_usd_volume
  FROM FLOW.CORE.EZ_STAKING_ACTIONS sa
  JOIN daily_prices dp ON date_trunc('day', sa.block_timestamp) = dp.day
  WHERE 
  block_timestamp >= current_date - 91
  AND
  action = 'DelegatorTokensCommitted'
  GROUP BY user_address
),

unstakes AS (
  SELECT
  delegator AS user_address,
  count(tx_id) AS n_unstakes,
  sum(amount) AS unstake_token_volume,
  sum(amount * price) AS unstake_usd_volume
  FROM FLOW.CORE.EZ_STAKING_ACTIONS sa
  JOIN daily_prices dp ON date_trunc('day', sa.block_timestamp) = dp.day
  WHERE 
  block_timestamp >= current_date - 91
  AND
  action = 'DelegatorUnstakedTokensWithdrawn'
  GROUP BY user_address
)

SELECT
coalesce(s.user_address, u.user_address) AS user_address,
'flow' AS protocol,
'A.16546533918040a61.FlowToken' AS token_contract,
'FlowToken' AS token_symbol,
COALESCE(n_stakes, 0) AS n_stakes,
COALESCE(n_unstakes, 0) AS n_unstakes,
COALESCE(stake_token_volume, 0) AS stake_token_volume,
COALESCE(stake_usd_volume, 0) AS stake_usd_volume,
COALESCE(unstake_token_volume, 0) AS unstake_token_volume,
COALESCE(unstake_usd_volume, 0) AS unstake_usd_volume
FROM stakes s
FULL OUTER JOIN unstakes u ON s.user_address = u.user_address",
api_key = api.key)


dex.swaps <- auto_paginate_query(query = "
WITH daily_prices AS (
SELECT 
  symbol,
  token_contract,
  date_trunc('day', timestamp) AS day,
  AVG(price_usd) AS price
FROM flow.core.fact_prices
WHERE timestamp > current_date - 91
GROUP BY symbol, token_contract, day
),
sells AS (
  SELECT
  trader AS user_address,
  symbol,
  swap_contract,
  token_out_contract AS token_contract,
  count(tx_id) AS n_sells,
  sum(token_out_amount) AS token_sell_volume,
  sum(token_out_amount * price) AS usd_sell_volume
  FROM
  flow.core.ez_swaps ds
  LEFT JOIN daily_prices dp ON date_trunc('day', ds.block_timestamp) = dp.day
      AND ds.token_out_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 91
  GROUP BY 
  trader, swap_contract, symbol, token_out_contract
),
buys AS (
  SELECT
  trader AS user_address,
  symbol,
  swap_contract,
  token_in_contract AS token_contract,
  count(tx_id) AS n_buys,
  sum(token_in_amount) AS token_buy_volume,
  sum(token_in_amount * price) AS usd_buy_volume
  FROM
  flow.core.ez_swaps ds
  LEFT JOIN daily_prices dp ON date_trunc('day', ds.block_timestamp) = dp.day
      AND ds.token_in_contract = dp.token_contract
  WHERE
  block_timestamp > current_date - 91
  GROUP BY 
  trader, swap_contract, symbol, token_in_contract
)

SELECT
COALESCE(sells.user_address, buys.user_address) AS user_address,
COALESCE(sells.swap_contract, buys.swap_contract) AS protocol,
COALESCE(sells.token_contract, buys.token_contract) AS token_contract,
COALESCE(sells.symbol, buys.symbol) AS token_symbol,
COALESCE(n_buys, 0) AS n_buys,
COALESCE(n_sells, 0) AS n_sells,
COALESCE(token_buy_volume, 0) AS buy_token_volume,
COALESCE(usd_buy_volume, 0) AS buy_usd_volume,
COALESCE(token_sell_volume, 0) AS sell_token_volume,
COALESCE(usd_sell_volume, 0) AS sell_usd_volume
FROM sells
FULL OUTER JOIN buys ON sells.user_address = buys.user_address
AND sells.swap_contract = buys.swap_contract
AND sells.token_contract = buys.token_contract
",
api_key = api.key)

# general tx counts
activity <- auto_paginate_query(query = "
--user_address | n_txn | n_days_active | days_since_last_txn | n_contracts
SELECT
proposer AS user_address,
count(tx_id) AS n_txn,
count(distinct(date_trunc('day', block_timestamp))) AS n_days_active,
DATEDIFF('days', date_trunc('day', max(block_timestamp)), current_date) AS last_txn,
0 AS n_complex_txn,
0 AS n_contracts
FROM flow.core.fact_transactions
WHERE
block_timestamp >= current_date - 91
AND
tx_succeeded = TRUE
AND 
proposer NOT IN (SELECT account_address FROM FLOW.CORE.DIM_CONTRACT_LABELS)
AND
proposer NOT IN (SELECT address FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS WHERE blockchain = 'flow')
GROUP BY
proposer
",
api_key = api.key)


# start putting all of the data together
user.stats <- merge(pack.rips[, list(n_rips = sum(n_rips)), by = user_address],
                    listings,
                    by = "user_address", all = TRUE)

# only dapper buys
user.stats <- merge(user.stats,
                    nft.sales[nf_token_contract %in% c('A.0b2a3299cc857e29.TopShot', 'A.e4cf4bdc1751c65d.AllDay', 
                                                       'A.329feb3ab062d289.UFC_NFT', 'A.87ca73a41bb50ad5.Golazos'),
                              list(n_nft_buys_dapper = sum(n_buys)), by = user_address],
                    by = "user_address", all = TRUE)

# only NOT dapper buys
user.stats <- merge(user.stats,
                    nft.sales[!(nf_token_contract %in% 
                                  c('A.0b2a3299cc857e29.TopShot', 'A.e4cf4bdc1751c65d.AllDay', 
                                    'A.329feb3ab062d289.UFC_NFT', 'A.87ca73a41bb50ad5.Golazos',
                                    'A.e4cf4bdc1751c65d.PackNFT', 'A.87ca73a41bb50ad5.PackNFT')),
                              list(n_nft_trades_nd = sum(n_buys) + sum(n_sells),
                                   n_nft_projects_nd = uniqueN(nf_token_contract)), by = user_address],
                    by = "user_address", all = TRUE)

user.stats <- merge(user.stats,
                    chain.stakes[, list(n_stakes = sum(n_stakes)), by = user_address],
                    by = "user_address", all = TRUE)

user.stats <- merge(user.stats,
                    dex.swaps[, list(n_swaps = sum(n_buys) + sum(n_sells)), by = user_address],
                    by = "user_address", all = TRUE)

# only keep users with nonzero entries
user.stats <- user.stats[user_address != "null" & (
  n_rips > 0 | n_listings > 0 | n_nft_buys_dapper > 0 | n_nft_trades_nd > 0 | n_nft_projects_nd > 0 | n_stakes > 0 
  )]

# replace NA's w 0's
ReplaceValues(user.stats)

# finally double check that we're not scoring any known non-user addresses
user.stats <- user.stats[!(user_address %in% c(flow.labels$address, flow.contracts$account_address))]


# grab the last data block to show on app
max.block <- auto_paginate_query(query = "SELECT max(block_timestamp) AS max_time, max(block_height) AS max_block FROM flow.core.fact_transactions",
                                 api_key = api.key)
                                 
last.blocks <- paste0("Data is updated through ", min(max.block$max_time), 
                      ", block number ", min(max.block$max_block))


# save file to run app
save(user.stats, last.blocks, file = '~/user_metrics/apps/flow/flowscored/flowscored_data.RData')








