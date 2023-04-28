# FLOWSCORED
#library(plotly)
library(data.table)
#library(shinyWidgets)
#library(shinyjs)
#library(stringr)
library(shinyBS)
library(googlesheets4)
# library(devtools)
# install_github("flipsidecrypto/user_metrics/apps/flow/dynamicWidget")
library(dynamicWidget)
library(jsonlite)


gs4_deauth()
fill.box <- read_sheet("https://docs.google.com/spreadsheets/d/1Mvp5lRpHiO2MI_loRA8RYYvKHQ2ipqtM8x-tnHQqU2Q/edit#gid=0", 
                       sheet = "flowscored_boxes")
fill.box <- as.data.table(fill.box)


if(Sys.info()[['user']] == "rstudio-connect") {
  file.location <- '/rstudio-data/flowscored_data.RData'
}  else {
  file.location <- 'data.RData'
}
load(file.location)
