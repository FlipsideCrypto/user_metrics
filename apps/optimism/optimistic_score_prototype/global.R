library(shinyBS)
library(data.table)
library(opAttestR)
library(rjson)

#library(devtools)
#install_github("flipsidecrypto/user_metrics/apps/optimism/opAttestR")
#install.packages("~/user_metrics/apps/optimism/opAttestR_0.0.0.9000.tar.gz", repos = NULL, type="source")

ifelse(Sys.info()[["user"]] == "rstudio-connect",
       load("/rstudio-data/optimist_score_prototype_data.RData"),
       load("data.RData"))

signerPrivateKey <- fromJSON(file="./secrets.json")$privateKey
provider <- fromJSON(file="./secrets.json")$provider

abi <- fromJSON(file="./abi/FlipsideAttestation.json")

