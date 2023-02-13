
library(data.table)
library(stringr) 
library(shinyWidgets)
library(plotly)
library(shinyjs)
#install_github("dreamRs/capture")
library(capture)
library(shinyBS)
library(dplyr)
library(solAttestR)
library(shinycssloaders)
# install_github("flipsidecrypto/user_metrics/apps/solana/solAttestR")
library(solAttestR)

wheel.colors <- c("#30CFCF", "#A682EE", "#23D1BA", "#9764E8", "#3EAFE0", "#8880E5", "#26D994")

svgdata <- readLines("wheel.svg")

user <- Sys.info()[['user']]
isRstudio <- user == 'rstudio-connect'
baseDir <- ifelse(isRstudio, '/rstudio-data/solarscored_data.RData', './')
file.location <- paste0(baseDir, 'solarscored_data.RData')
load(file.location)
# print(exists("score.criteria"))
score_criteria <- read.csv(
    paste0(baseDir, 'score_criteria.csv')
  ) %>% as.data.table()

bar.plot.colors <- c("#14F195", "#B2FBDC")


# setnames(df2, c("user_address", "longevity", "activity", "governor", "bridgor", "staker", "explorer", "nfts", 
#                 "longevity1", "longevity2", "longevity3", "activity1", "activity2", "activity3", "governance1", "governance2", "governance3",
#                 "bridging1", "bridging2", "bridging3", "staking1", "staking2", "staking3", 
#                 "diversification1", "diversification2", "diversification3", "nfts1", "nfts2", "nfts3", "total_score"))

base.style <- rep("20%", times = 21)

categories <- c("nfts", "governance", "variety", "staking", "longevity", "bridge", "activity")


empty.df <- data.table(total_score=0,longevity=0,longevity_value=0,activity=0,activity_value=0,governance=0,governance_value=0,bridge=0,bridge_value=0,staking=0,staking_value=0,variety=0,variety_value=0,nfts=0,nft_value=0)

