library(shroomDK)

#source("~/data_science/util/util_functions.R")
# need to replace query snowflake with shrrom dk's


airdrop.claims <- QuerySnowflake(paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"))
cex.activity <- QuerySnowflake(paste(readLines("~/user_metrics/sql/bags/optimism/cex_activity.sql"), collapse = "\n"))
chain.stakes <- QuerySnowflake(paste(readLines("~/user_metrics/sql/governance/optimism/chain_stakes.sql"), collapse = "\n"))
nft.trades <- QuerySnowflake(paste(readLines("~/user_metrics/sql/nfts/optimism/nft_trades.sql"), collapse = "\n"))
dex.swaps <- QuerySnowflake(paste(readLines("~/user_metrics/sql/defi/optimism/dex_swaps.sql"), collapse = "\n"))

# dex.swaps <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"), 
#                                  api_key = readLines("api_key.txt"))
# 
# dex.swaps <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"), 
#                                  api_key = readLines("api_key.txt"))
# 
# dex.swaps <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"), 
#                                  api_key = readLines("api_key.txt"))
# 
# dex.swaps <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"), 
#                                  api_key = readLines("api_key.txt"))
# 
# dex.swaps <- data.table(auto_paginate_query(query = paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"), 
#                                  api_key = readLines("api_key.txt")))

op.metrics.w <- MergeDataFrames(
  list(airdrop.claims[, list(user_address, airdrop_tokens_claimed = token_volume)],
       cex.activity[, list(user_address, net_cex_wdraw = wdraw_usd_volume - dep_usd_volume)],
       chain.stakes[, list(user_address, n_delegations = n_stakes)],
       nft.trades[, list(n_trades = sum(n_buys + n_sells)), by = user_address],
       dex.swaps),
  by = "user_address", all = TRUE
)




ReplaceValues(op.metrics.w)

op.metrics.w[, airdrop_score := ifelse(airdrop_tokens_claimed > 0, 1, 0)]
op.metrics.w[, cex_score := ifelse(net_cex_wdraw >= 0, 1, 0)]
op.metrics.w[, delegation_score := ifelse(n_delegations > 0, 1, 0)]
op.metrics.w[, nft_score := ifelse(n_trades > 0, 1, 0)]
op.metrics.w[, dex_score := ifelse(n_swaps > 0, 1, 0)]

op.metrics.w[, total_score := airdrop_score + cex_score + delegation_score + nft_score + dex_score]

# op.metrics.w[, .N, by = total_score][order(total_score)]
op.metrics.w <- op.metrics.w[total_score > 0]

save(op.metrics.w, file = "data.RData")

#op.metrics.w[user_address == tolower("0xf76e2d2bba0292cf88f71934aff52ea54baa64d9")]

