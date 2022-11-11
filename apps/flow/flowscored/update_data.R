# https://github.com/FlipsideCrypto/sdk/tree/main/r/shroomDK
source("~/data_science/util/util_functions.R")

  
setwd("~/user_metrics/")
activity.stats.query <- paste(readLines("sql/activity/flow/activity_stats.sql"), collapse = "\n")
activity.stats <- QuerySnowflake(activity.stats.query)

dex.swaps.query <- paste(readLines("sql/defi/flow/dex_swaps.sql"), collapse = "\n")
dex.swaps <- QuerySnowflake(dex.swaps.query)

lp.activity.query <- paste(readLines("sql/defi/flow/lp_activity.sql"), collapse = "\n")
#lp.activity <- QuerySnowflake(lp.activity.query)

defi.staking.query <- paste(readLines("sql/defi/flow/staking.sql"), collapse = "\n")
defi.staking <- QuerySnowflake(defi.staking.query)

chain.stakes.query <- paste(readLines("sql/governance/flow/chain_stakes.sql"), collapse = "\n")
chain.stakes <- QuerySnowflake(chain.stakes.query)

nft.trades.query <- paste(readLines("sql/nfts/flow/nft_trades.sql"), collapse = "\n")
nft.trades <- QuerySnowflake(nft.trades.query)
nft.trades[, n_trades := n_buys + n_sells]
nft.trades[, profit_usd := sell_usd_volume - buy_usd_volume]

nft.trades[, list(user_profit_usd = sum(profit_usd), n_trades = sum(n_trades)), by = "user_address,nf_token_contract"] %>% 
  .[, list(n_users = uniqueN(user_address), prop_profitiable = mean(user_profit_usd > 0), n_trades = sum(n_trades)/2), by = nf_token_contract] %>%
  .[order(prop_profitiable)]


nft.listings.query <- paste(readLines("sql/nfts/flow/nft_listings.sql"), collapse = "\n")
nft.listings <- QuerySnowflake(nft.listings.query)

nft.lending.query <- paste(readLines("sql/nfts/flow/nft_lending.sql"), collapse = "\n")
nft.lending <- QuerySnowflake(nft.lending.query)

cex.activity.query <- paste(readLines("sql/bags/flow/cex_activity.sql"), collapse = "\n")
cex.activity <- QuerySnowflake(cex.activity.query)

bridge.activity.query <- paste(readLines("~/user_metrics/sql/bags/flow/bridge_activity.sql"), collapse = "\n")
bridge.activity <- QuerySnowflake(bridge.activity.query)

token.accumulation.query <- paste(readLines("sql/bags/flow/token_accumulation.sql"), collapse = "\n")
token.accumulation <- QuerySnowflake(token.accumulation.query)
token.accumulation <- token.accumulation[token_in_volume > 0.001 | token_out_volume > 0.001]

flow.labels <- QuerySnowflake("SELECT * FROM FLIPSIDE_PROD_DB.CROSSCHAIN.ADDRESS_LABELS where blockchain = 'flow'")
flow.contracts <- QuerySnowflake("SELECT * FROM flow.core.dim_contract_labels")

nft.profits <- nft.trades[, list(user_profit_usd = sum(profit_usd), n_trades = sum(n_trades)), by = "user_address,nf_token_contract"] %>%
  .[, list(n_users = uniqueN(user_address), prop_profitiable = mean(user_profit_usd > 0), n_trades = sum(n_trades)/2), by = nf_token_contract] %>%
  .[order(-prop_profitiable)]

coolness[1:10]
ggplot(coolness,
       aes(x = n_users, y = n_trades, size = prop_profitiable)) +
  geom_point()







# # increment fi
# flow.contracts <- QuerySnowflake("SELECT * FROM flow.core.dim_contract_labels")
# flow.contracts[str_detect(tolower(contract_name), "fi")]
# 
# "SwapFactory"
# flow.contracts[account_address == "0xb063c16cac85dbd1"]
# flow.contracts[account_address == "0xecbda466e7f191c7"]
# 
# "SwapRouter"
# flow.contracts[account_address == "0xa6850776a94e6551"]
# "SwapPair (Template contract)"
# "SwapInterfaces, SwapConfig, SwapError"
# flow.contracts[account_address == "0xb78ef7afa52ff906"]
# 
# # a thing?
# # A.39e42c67cc851cfb.EmeraldIdentityDapper       EmeraldIDCreated    6769
# 
# # my increment finance swap:
# "eb2c1c7d496807d53bba076cc1c3afe16552b9e757d3a41323598b33fd2ddf96"
# 
# all.contracts.events[str_detect(tolower(event_type), "dep")]
# 
# all.contracts.events[str_detect(tolower(event_contract), "dapp")]
# 
# dex.swaps[, .N, by = "token_contract"]
# 
# all.contracts.events.swaps <- QuerySnowflake("select event_contract, event_type, count(tx_id) as n_txn from FLOW.CORE.FACT_EVENTS
# where block_timestamp > current_date - 90
# AND event_type = 'Swap'
# group by event_contract, event_type")


# basic stats:

# trades
flowscored.metrics <- nft.trades[, list(metric_name = "nft_n_trades", metric = n_trades), by = list(user_address)]
# days since last tx
flowscored.metrics <- rbind(flowscored.metrics,
                            activity.stats[, list(user_address, metric_name = "days_since_last_tx", metric = last_txn)])
# different nft projects traded
flowscored.metrics <- rbind(flowscored.metrics,
                            nft.trades[, list(metric_name = "nft_n_projects", metric = uniqueN(nft_project)), by = list(user_address)])
# listings
flowscored.metrics <- rbind(flowscored.metrics,
                            nft.listings[, list(metric_name = "nft_n_listings", metric = n_listings), by = list(user_address)])

flowscored.metrics.w <- dcast.data.table(flowscored.metrics,
                                        user_address ~ metric_name, value.var = "metric", fun.aggregate = sum, fill = 0)


# noteable actions
flowscored.metrics.w[, list_nft := ifelse(user_address %in% nft.listings$user_address, 1, 0)]
flowscored.metrics.w[, bought_nfts := ifelse(user_address %in% nft.trades[n_buys > 0]$user_address, 1, 0)]

flowscored.metrics.w[, staked_flow := ifelse(user_address %in% chain.stakes[n_stakes > 0]$user_address, 1, 0)]
flowscored.metrics.w[, dex_swapper := ifelse(user_address %in% dex.swaps$user_address, 1, 0)]


# # top x% y trader
flowscored.metrics.w[, top_topshot_trader := round(runif(nrow(flowscored.metris.w)))]

# 90 +ve profits
flowscored.metrics.w[, positive_trader := round(runif(nrow(flowscored.metris.w)))]


save(flowscored.metrics.w, file = "~/user_metrics/apps/flow/flowscored/data.RData")
setwd("~/user_metrics/apps/flow/flowscored/")


if(FALSE) {
# floats (p2e/dapps/games)
# claim float FLOATClaimed
# create float event FLOATEventCreated

# flovatar builder
# build a flowvatar 

# incrementFi

# lp 
# need all of the pairs!
# "TokensDeposited", "TokensWithdrawn"
# should be made by 0xb063c16cac85dbd1
# router is 0xa6850776a94e6551


# # farmDONE
# flow.contracts[account_address == "0x1b77ba4b414de352"]
# all.contracts.events[event_contract == "A.1b77ba4b414de352.Staking"]
# "TokenStaked"
# "TokenUnstaked"


# lend/borrow
c("Borrow", "Supply", "Repay", "Redeem")
# FLOW
"0x7492e2f9b4acea9a"
#fUSD
"0x90f55b24a556ea45"
#USDC
"0x8334275bda13b2be"
#BLT
"0x67539e86cbe9b261"

# stake FLOW (does this double count though?)
flow.contracts[account_address == "0xd6f80565193ad727"]
all.contracts.events[event_contract == "A.d6f80565193ad727.LiquidStaking"]
# LiquidStaking
"0xd6f80565193ad727"
# "Stake" "Unstake"


# flowty!!
all.contracts.events[str_detect(tolower(event_contract), "flowty")][order(event_contract, event_type)]

A.5c57f79c6694797f.Flowty
# list nft ListingAvailable, ListingCompleted (?)
# user = lister

# get funding (FundingAvailable, FundingSettled)
# lister, funder
# repay funding FundingRepaid
# lister, funder

# list rental ListingAvailable
# lister
# rent ListingRented
# lister, renter
# return RentalReturned
# lister, renter
}






# what do I want?

# basic actions by wallet creator:

chain.stakes <- merge(chain.stakes,
                      wallet.creations[user_address %in% chain.stakes$user_address, 
                                       list(user_address, wallet_creator)],
                      by = "user_address", all.x = TRUE, all.y = FALSE)

dex.swaps <- merge(dex.swaps,
                      wallet.creations[user_address %in% dex.swaps$user_address, 
                                       list(user_address, wallet_creator)],
                      by = "user_address", all.x = TRUE, all.y = FALSE)

nft.trades <- merge(nft.trades,
                   wallet.creations[user_address %in% nft.trades$user_address, 
                                    list(user_address, wallet_creator)],
                   by = "user_address", all.x = TRUE, all.y = FALSE)


token.accumulation <-  merge(token.accumulation,
                             wallet.creations[user_address %in% token.accumulation$user_address, 
                                              list(user_address, wallet_creator)],
                             by = "user_address", all.x = TRUE, all.y = FALSE)

letsee <- rbind(
token.accumulation[, list(wallet_creator, user_address, what = 'tokenstuff')],
chain.stakes[, list(wallet_creator, user_address, what = 'stakeflow')],
dex.swaps[, list(wallet_creator, user_address, what = 'swap')],
nft.trades[, list(wallet_creator, user_address, what = 'tradenft')])

data.table::dcast(letsee, wallet_creator ~ what, value.var = "user_address", fun.aggregate = uniqueN)


nft.trades[wallet_creator == "blocto", .N, by = "marketplace,nf_token_contract"][order(-N)]
















