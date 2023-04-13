source("~/data_science/util/util_functions.R")



user.data <- QuerySnowflake("with satellite_token_address_coingecko_token_address_chain AS (
  SELECT COLUMN1 as AXL_TOKEN_ADDRESS, COLUMN2 AS CHAIN_TOKEN_ADDRESS, COLUMN3 as BLOCKCHAIN FROM (
VALUES 
('uatom','ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2','cosmos'),
('uaxl','ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E', 'cosmos'),
('0x6e4e624106cb12e168e6533f8ec7c82263358940','ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E', 'cosmos'),
('0x467719ad09025fcc6cf6f8311755809d45a5e5f3','ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E', 'cosmos'),
('0x44c784266cf024a60e8acf2427b9857ace194c5d','ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E', 'cosmos'),
('0x8b1f4432f943c465a973fedc6d7aa50fc96f1f65','ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E', 'cosmos'),
('0x1b7c03bc2c25b8b5989f4bc2872cf9342cec80ae','ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E', 'cosmos'),
('0x23ee2343b892b1bb63503a4fabc840e0e2c6810f','ibc/903A61A498756EA560B85A85132D3AEE21B5DEDD41213725D22ABF276EA6945E', 'cosmos'),
('0x80d18b1c9ab0c9b5d6a6d5173575417457d00a12','ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2','cosmos'),
('0x33f8a5029264bcfb66e39157af3fea3e2a8a5067','ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2','cosmos'),
('0x27292cf0016e5df1d8b37306b2a98588acbd6fca','ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2','cosmos'),
('avalanche-uusdc','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0xddc9e2891fa11a4cc5c223145e8d14b44f3077c9','0x6b175474e89094c44da98b954eedeac495271d0f', 'ethereum'),
('0xc5fa5669e326da8b2c35540257cd48811f40a36b','0x6b175474e89094c44da98b954eedeac495271d0f', 'ethereum'),
('0x4914886dbb8aad7a7456d471eaab10b06d42348d','0x853d955acef822db058eb8505911ed77f175b99e','ethereum'),
('0x53adc464b488be8c5d7269b9abbce8ba74195c3a','0x853d955acef822db058eb8505911ed77f175b99e','ethereum'),
('frax-wei','0x853d955acef822db058eb8505911ed77f175b99e','ethereum'),
('0x853d955acef822db058eb8505911ed77f175b99e','0x853d955acef822db058eb8505911ed77f175b99e','ethereum'),
('0x750e4c4984a9e0f12978ea6742bc1c5d248f40ed','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0xfab550568c688d5d8a52c7d794cb93edc26ec0ec','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0x4268b8f0b87b6eae5d897996e6b845ddbd99adf3','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0xeb466342c4d449bc9f53a865d5cb90586f405215','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0xceed2671d8634e3ee65000edbbee66139b132fbf','0xdac17f958d2ee523a2206206994597c13d831ec7', 'ethereum'),
('0xf976ba91b6bb3468c91e4f02e68b37bc64a57e66','0xdac17f958d2ee523a2206206994597c13d831ec7', 'ethereum'),
('0x7f5373ae26c3e8ffc4c77b7255df7ec1a9af52a6','0xdac17f958d2ee523a2206206994597c13d831ec7', 'ethereum'),
('0xdac17f958d2ee523a2206206994597c13d831ec7','0xdac17f958d2ee523a2206206994597c13d831ec7', 'ethereum'),
('uusdt','0xdac17f958d2ee523a2206206994597c13d831ec7', 'ethereum'),
('0x4fabb145d64652a948d72533023f6e7a623c7c53','0xe9e7cea3dedca5984780bafc599bd69add087d56', 'bsc'),
('busd-wei','0xe9e7cea3dedca5984780bafc599bd69add087d56', 'bsc'),
('dai-wei','0x6b175474e89094c44da98b954eedeac495271d0f', 'ethereum'),
('polygon-uusdc','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('uusdc','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0x6b175474e89094c44da98b954eedeac495271d0f','0x6b175474e89094c44da98b954eedeac495271d0f', 'ethereum'),
('0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0x2791bca1f2de4661ed88a30c99a7a9449aa84174', '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'ethereum'),
('wavax-wei','0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7', 'avalanche'),
('0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7','0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7', 'avalanche'),
('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2','0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2','ethereum'),
('weth-wei','0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2','ethereum'),
('wbtc-satoshi','0x2260fac5e5542a773aa44fbcfedf7c193bc2c599', 'ethereum'),
('0x2260fac5e5542a773aa44fbcfedf7c193bc2c599','0x2260fac5e5542a773aa44fbcfedf7c193bc2c599', 'ethereum'),
('dot-planck','0xffffffffffffffffffffffffffffffffffffffff','polkadot'),
('wftm-wei','0x4e15361fd6b4bb609fa63c81a2be19d873717870','ethereum'),
('link-wei','0x514910771af9ca656af840dff83e8264ecf986ca','ethereum'),
('0x514910771af9ca656af840dff83e8264ecf986ca','0x514910771af9ca656af840dff83e8264ecf986ca','ethereum'),
('mkr-wei','0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2','ethereum'),
('wbnb-wei','0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c','bsc'),
('0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c','0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c','bsc'),
('wmatic-wei','0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270','polygon'),
('0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270','0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270','polygon')
)
),  

squid_hr_sender_og_dest_amount AS (
SELECT 'squid' as method, DATE_TRUNC('hour', BLOCK_TIMESTAMP) as hr, tx_hash, sender, 
token_address as AXL_TOKEN_ADDRESS, token_symbol, amount, source_chain, destination_chain
  FROM axelar.core.ez_squid
), 

satellite_hr_sender_og_dest_amount AS (
SELECT 'satellite' as method, DATE_TRUNC('hour', BLOCK_TIMESTAMP) as hr, tx_hash, sender, 
token_address as AXL_TOKEN_ADDRESS, token_symbol, amount, source_chain, destination_chain
FROM axelar.core.ez_satellite
),
 
all_sends AS 
(
SELECT * FROM squid_hr_sender_og_dest_amount 
UNION (SELECT * FROM satellite_hr_sender_og_dest_amount)
),

all_sends_labeled_id AS (
SELECT * FROM all_sends 
  INNER JOIN satellite_token_address_coingecko_token_address_chain USING (AXL_TOKEN_ADDRESS)
),

-- Infill missing hour prices with most recent non-missing hour price
all_sends_priced AS (
SELECT *, 
coalesce(price, lag(price) IGNORE NULLS over (partition by CHAIN_TOKEN_ADDRESS, BLOCKCHAIN order by HR)) as imputed_price
FROM all_sends_labeled_id
 LEFT JOIN (
    SELECT TOKEN_ADDRESS as CHAIN_TOKEN_ADDRESS, 
            DATE_TRUNC('hour', HOUR) as hr, BLOCKCHAIN,
           price
      FROM crosschain.core.fact_hourly_prices
    WHERE provider = 'coingecko'
  ) 
USING(CHAIN_TOKEN_ADDRESS, BLOCKCHAIN, hr)
),

-- For transactions BEFORE fact_hourly_token_price has a price
-- Use the FIRST price ever recorded in fact_hourly_token_price
-- Otherwise, use actual hourly OR imputed (most recent) hourly price
-- Close -> price -> imputed_price -> final_price
all_sends_priced_final AS (
SELECT *, 
coalesce(imputed_price,
    FIRST_VALUE(imputed_price IGNORE NULLS) OVER (PARTITION BY CHAIN_TOKEN_ADDRESS, BLOCKCHAIN ORDER BY HR)) AS final_price
FROM all_sends_priced
)

-- gotta send at least $1 between chains
SELECT SENDER, source_chain, destination_chain, method,
 max(hr) AS last_transfer,
 count(*) as n_transfers, 
 sum(amount*final_price) as total_usd
FROM all_sends_priced_final
GROUP BY SENDER, source_chain, destination_chain, method
HAVING total_usd >= 1")

# saved.user.data <- copy(user.data)
# user.data <- copy(saved.user.data)

user.data[source_chain == "osmo", source_chain := "osmosis"]
user.data[destination_chain == "osmo", source_chain := "osmosis"]

user.data[source_chain == "cosmos", source_chain := "cosmoshub"]
user.data[destination_chain == "cosmos", source_chain := "cosmoshub"]


library(googlesheets4)
gs4_deauth()
chains <- read_sheet("https://docs.google.com/spreadsheets/d/1DAYDqM1h0HSX7Otqveb8DcXNfTN8sSa4JaDDW9_F-7A/edit#gid=0", sheet = "map_coordinates")
chains <- as.data.table(chains)

# chains[station %notin% c("aptos", "sui")]$station[which(chains[station %notin% c("aptos", "sui")]$station %notin% unique(c(user.data$source_chain, user.data$destination_chain)))]
# sort(unique(c(user.data$source_chain, user.data$destination_chain)))

user.data <- user.data[source_chain %in% chains$station | destination_chain %in% chains$station]

user.data <- merge(user.data, 
                   chains[, list(source_chain = station, source_island = island, source_chain_type = chain_type)], 
                   by = "source_chain")
user.data <- merge(user.data, 
                   chains[, list(destination_chain = station, destination_island = island, destination_chain_type = chain_type)], 
                   by = "destination_chain")

user.data[, conn_alpha := paste(sort(c(source_island, destination_island)), collapse = "|"), 
          by = list(sender, source_island, destination_island, method)]

user.conns <- lapply(user.data[source_island != destination_island]$sender, function(i) {
  #print(i)
  user.conns <- user.data[sender == i, 
                          .N, 
                          by = list(method,conn_alpha)][order(method, conn_alpha)]
  user.conns[, conn1 := strsplit(conn_alpha, "|", fixed = TRUE)[[1]][1], by = conn_alpha]
  user.conns[, conn2 := strsplit(conn_alpha, "|", fixed = TRUE)[[1]][2], by = conn_alpha]
  
  all.conns <- c()
  
  for(i in 1:nrow(user.conns)) {
    
    if(user.conns[i]$method == "squid") {
      
      all.conns <- c(all.conns, paste("squid", user.conns[i]$conn1, user.conns[i]$conn2, sep = "_"))
      
    } else {
      
      all.conns <- c(all.conns, paste0("bridge_", c(user.conns[i]$conn1, user.conns[i]$conn2)[which(c(user.conns[i]$conn1, user.conns[i]$conn2) != "axelar")]))
      
    }
    
  }
  
  if(length(all.conns) > 0) {
    return(unique(all.conns))
  } else {
    return("")
  }
  
})

names(user.conns) <- user.data[source_island != destination_island]$sender


# write a function to spit out the user persona:

# Persona: Cosmonaut
# Only transacts ibc
# Cosmonaut Levels:
# Base: 1tx
# Wide-Eyed: 2 to 4 tx
# Power: 5+ tx
# 
# Persona: Etherererer
# Only transacts in evm
# Etherererer Levels:
# Base: 1tx
# Wide-Eyed: 2 to 4 tx
# Power: 5+ tx
# 
# Omnivore
# Transacts in >1 island
# Traveler: has transacted evm to ibc or ibc to evm
# Power-User: Have done 5+ transactions across islands
# getUserPersona <- function(tmp.user.data) {
#   if( sum(c("ibc", "evm") %in% chain.types) == 2 ) {
#     #"omnivore"
#     
#     which.subpersona <- as.numeric(sum(tmp.user.data$n_transfers) >= 5) + 1
#     
#     data.table(persona = c("travelling omnivore", "powerful omnivore")[which.subpersona],
#                icon1 = "globe",
#                icon2 = c("plane", "crown")[which.subpersona])
#     
#   } else if( sum("ibc" %in% chain.types) ) {
#     "cosmonaut"
#     
#     which.subpersona <- max(which(sum(tmp.user.data$n_transfers) >= c(0, 2, 5)))
#     
#     data.table(persona = c("junior cosmonaut", "wide-eyed cosmonaut", "powerful cosmonaut")[which.subpersona],
#                icon1 = "moon",
#                icon2 = c("child", "eye", "crown")[which.subpersona])
#     
#   } else {
#     "ethplorer"
#     
#     which.subpersona <- max(which(sum(tmp.user.data$n_transfers) >= c(0, 2, 5)))
#     
#     data.table(persona = c("junior ethplorer", "wide-eyed ethplorer", "powerful ethplorer")[which.subpersona],
#                icon1 = "map-signs",
#                icon2 = c("child", "eye", "crown")[which.subpersona])
#     
#   }
# }

# axelar stats:
axelar.stats <- data.table(no1_destination = user.data[, .N, by = destination_chain][order(-N)][1]$destination_chain,
                           no1_source = user.data[, .N, by = source_chain][order(-N)][1]$source_chain,
                           avg_xfer_usd = paste0("$", format(round(sum(user.data$total_usd) / sum(user.data$n_transfers)), big.mark = ",")))


save(user.data, user.conns, axelar.stats, file = "data.RData")







