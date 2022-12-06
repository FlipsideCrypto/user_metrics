library(metamaskConnectr)
library(shinyBS)
library(data.table)

load("data.RData")
signer_private_key <- readLines("secrets.txt")