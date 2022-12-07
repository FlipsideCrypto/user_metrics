library(shinyBS)
library(data.table)
library(opAttestR)
library(rjson)

#library(devtools)
#install_github("flipsidecrypto/user_metrics/apps/optimism/opAttestR")


load("data.RData")

signerPrivateKey <- fromJSON(file="./secrets.json")$privateKey
provider <- fromJSON(file="./secrets.json")$provider

abi <- fromJSON(file="./abi/FlipsideAttestation.json")

