library(shiny)
library(r2d3)
library(data.table)
library(shinyBS)
# library(devtools)
# install_github("flipsidecrypto/user_metrics/apps/axelar/cosmosDynamicWidget")
library(cosmosDynamicWidget)
library(magrittr)
library(jsonlite)
library(stringr)

ifelse(Sys.info()[["user"]] == "rstudio-connect",
       load("/rstudio-data/axelscore_data.RData"),
       load("axelscore_data.RData"))



map.data <- fread("map_coordinates.csv")
map.connections <- fread("map_connections.csv")
promo.criteria <- fread("promo_criteria.csv")


if(FALSE) {
  network.data <- list(
    nodes = data.table(station = c("axelar", 
                                   "moonbeam", "fantom", "binance", 
                                   "avalanche", 
                                   "ethereum", "polygon", "arbitrum", "optimism", 
                                   "osmosis", "cosmoshub", "evmos", "stride", "injective", 
                                   "aptos", "sui"),
                       islands = c("axelar", rep('other', 3), 'avalanche', rep("evm", 4), rep("ibc", 5), rep("soontm", 2)),
                       xprop = c(0.5, #axelar
                                 .18, .26, .139, # other
                                 .848, # avalanche
                                 .707, .888, .869, .733, #evm
                                 .215, .273, .212, .134, .122, # ibc
                                 .159, .111), # soontm
                       yprop = c(0.5, 
                                 .41, .23, .244, 
                                 .206, 
                                 .729, .692, .804, .836, 
                                 .677, .756, .847, .794, .711, 
                                 .485, .146
                       ),
                       selected = "grey"),
    
    edges = data.table(source_chain = c("axelar", "avalanche"),
                       destination_chain = c("avalanche", "axelar"),
                       x1 = c(.538, .556),
                       y1 =  c(.500, .523),
                       x2 = c(.777, .794),
                       y2 = c(.267, .290),
                       selected = "no")
  )
}

trending <- fromJSON(readLines("https://flipsidecrypto.xyz/api/discover/get?d_project=axelar&d_sort=trending"))

trending.links <- data.table(link_text = trending$dashboards$title[1:3],
                             link_url = trending$dashboards$url[1:3]
           # link_url  = paste0("https://flipsidecrypto.xyz/", 
           #                    trending$dashboards$username[1:3], 
           #                    "/", 
           #                    str_replace_all(tolower(trending$dashboards$title[1:3]), " ", "-"),
           #                    "-",
           #                    trending$dashboards$slug[1:3])
)

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1, 1)), substring(s, 2),
        sep = "", collapse = " ")
}
