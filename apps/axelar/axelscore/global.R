library(shiny)
library(r2d3)
library(data.table)
library(dynamicWidget)
library(shinyBS)

load("data.RData")


# map.data <- fread("map_coordinates.csv")
# map.connections <- fread("map_connections.csv")

library(googlesheets4)
gs4_deauth()
map.data <- as.data.table(read_sheet("https://docs.google.com/spreadsheets/d/1DAYDqM1h0HSX7Otqveb8DcXNfTN8sSa4JaDDW9_F-7A/edit#gid=0", 
                                     sheet = "map_coordinates"))
map.connections <- as.data.table(read_sheet("https://docs.google.com/spreadsheets/d/1DAYDqM1h0HSX7Otqveb8DcXNfTN8sSa4JaDDW9_F-7A/edit#gid=0", 
                                            sheet = "connections"))


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



#r2d3::r2d3("makesubd3.js", data= jsonlite::toJSON(network.data))


