library(shroomDK)
library(data.table)

airdrop.claims <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/airdrops/optimism/airdrop_claims.sql"), collapse = "\n"),
                                      api_key = readLines("api_key.txt"))

cex.activity <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/bags/optimism/cex_activity.sql"), collapse = "\n"),
                                    api_key = readLines("api_key.txt"))

chain.stakes <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/governance/optimism/chain_stakes.sql"), collapse = "\n"),
                                    api_key = readLines("api_key.txt"))

nft.trades <- auto_paginate_query(query = paste(readLines("~/user_metrics/sql/nfts/optimism/nft_trades.sql"), collapse = "\n"),
                                  api_key = readLines("api_key.txt"))

dex.swaps <- data.table(auto_paginate_query(query = paste(readLines("~/user_metrics/sql/defi/optimism/dex_swaps.sql"), collapse = "\n"),
                                            api_key = readLines("api_key.txt")))

op.metrics.w <- merge(airdrop.claims[, list(user_address, airdrop_tokens_claimed = token_volume)],
                      cex.activity[, list(user_address, net_cex_wdraw = wdraw_usd_volume - dep_usd_volume)],
                      by = "user_address", all = TRUE)

op.metrics.w <- merge(op.metrics.w,
                      chain.stakes[, list(user_address, n_delegations = n_stakes)],
                      by = "user_address", all = TRUE)

op.metrics.w <- merge(op.metrics.w,
                      cnft.trades[, list(n_trades = sum(n_buys + n_sells)), by = user_address],
                      by = "user_address", all = TRUE)

op.metrics.w <- merge(op.metrics.w,
                      dex.swaps,
                      by = "user_address", all = TRUE)

op.metrics.w[, airdrop_score := ifelse(airdrop_tokens_claimed > 0, 1, 0)]
op.metrics.w[, cex_score := ifelse(net_cex_wdraw >= 0, 1, 0)]
op.metrics.w[, delegation_score := ifelse(n_delegations > 0, 1, 0)]
op.metrics.w[, nft_score := ifelse(n_trades > 0, 1, 0)]
op.metrics.w[, dex_score := ifelse(n_swaps > 0, 1, 0)]

op.metrics.w[, total_score := airdrop_score + 1 + delegation_score + nft_score + dex_score]

op.metrics.w <- op.metrics.w[total_score > 0]

save(op.metrics.w, file = "data.RData")


