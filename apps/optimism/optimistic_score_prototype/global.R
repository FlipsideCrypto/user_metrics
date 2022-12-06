library(metamaskConnectr)
library(shinyBS)
library(data.table)

load("data.RData")


#library(devtools)
#install_github("flipsidecrypto/tools/metamaskConnectr")

signer_private_key <- readLines("secrets.txt")

