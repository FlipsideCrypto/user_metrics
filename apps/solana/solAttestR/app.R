library(shiny)
library(solAttestR)
library(rjson)

# setwd('~/git/user_metrics/apps/solana/solAttestR')
# install.packages("~/user_metrics/apps/solana/solAttestR_0.0.0.9000.tar.gz", repos = NULL, type="source")

ui <- fluidPage(
  titlePanel("reactR Input Example2"),
  SolWalletHandler("eth_address"),
)
server <- function(input, output, session) {
  observeEvent(input$eth_address, {
    print(cat("eth_address: ", input$eth_address))
  })
}

shinyApp(ui, server)