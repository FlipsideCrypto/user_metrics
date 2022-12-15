library(shiny)
library(opAttestR)
library(rjson)

provider <- fromJSON(file="./secrets.json")$provider

abi <- fromJSON(file="./abi/FlipsideAttestation.json")

ui <- fluidPage(
  titlePanel("reactR Input Example"),
  WalletHandler("eth_address", chainId = 10),
  uiOutput("tx_handler"),
)
server <- function(input, output, session) {
  observeEvent(input$eth_address, {
    print(cat("eth_address: ", input$eth_address))
  })

  print(provider)

  output$tx_handler <- renderUI({
    TransactionHandler(
        "tx_button", 
        chainId = 10,
        label = "Make Attestation",
        contract_address = "0xD870A73a32d0b8C34CcF1E6098E9A26977CB605b",
        contract_abi = abi,
        contract_method = "attest",
        provider = provider,
        args = c(input$eth_address, "Flipside_user_scoring", 5),
        enabled = TRUE
    )
  })
}

shinyApp(ui, server)