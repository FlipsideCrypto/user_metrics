install.packages("shroomDK")
source("~/data_science/util/util_functions.R")


airdrop.claims <- QuerySnowflake(paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"))
cex.activity <- QuerySnowflake(paste(readLines("~/user_metrics/sql/bags/optimism/cex_activity.sql"), collapse = "\n"))
chain.stakes <- QuerySnowflake(paste(readLines("~/user_metrics/sql/governance/optimism/chain_stakes.sql"), collapse = "\n"))
nft.trades <- QuerySnowflake(paste(readLines("~/user_metrics/sql/nfts/optimism/nft_trades.sql"), collapse = "\n"))
dex.swaps <- QuerySnowflake(paste(readLines("~/user_metrics/sql/defi/optimism/dex_swaps.sql"), collapse = "\n"))


















