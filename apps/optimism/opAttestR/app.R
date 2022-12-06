library(shiny)
library(opAttestR)
library(rjson)

privateKey <- fromJSON(file="./secrets.json")$privateKey
provider <- fromJSON(file="./secrets.json")$provider

abi <- fromJSON(file="./abi/FlipsideAttestation.json")

signature <- "0x0000000000000000000000000000000000000000000000000000000000000000"
eth_address <- "0x0000000000000000000000000000000000000000"

ui <- fluidPage(
  titlePanel("reactR Input Example"),
  WalletHandler("eth_address", chainId = 420),
  uiOutput("signature"),
)
  # uiOutput("tx_handler"),

server <- function(input, output, session) {
  observeEvent(input$eth_address, {
    print(input$eth_address)
  })

  print(privateKey)
  print(provider)

  # output$tx_handler <- renderUI({
  #   TransactionHandler(
  #       "tx_button", 
  #       label = "Make Attestation",
  #       contract_address = "0xD870A73a32d0b8C34CcF1E6098E9A26977CB605b",
  #       contract_abi = abi,
  #       contract_method = "attest",
  #       args = c(eth_address, "Flipside_user_scoring", 5, signature),
  #       enabled = FALSE
  #   )
  # })

  output$signature <- renderUI({
    SignMessageBackend(
      "sign_message",
      chainId=420,
      privateKey=privateKey,
      provider=provider,
      messageArguments=c(
        input$eth_address,
        "Flipside_user_scoring",
        5
      )
    )
  })

  # output$signature <- textOutput({
  #   SignMessageBackend(
  #       "sign_message",
  #       privateKey=privateKey,
  #       provider=provider,
  #       messageArguments=c(
  #         input$eth_address,
  #         "Flipside_user_scoring",
  #         5
  #       )
  #   )
  # })

  # observeEvent(output$signature, {
  #   print("signature", output$signature)
  # })

  # output$tx_handler <- renderUI({
  #   TransactionHandler(
  #       "tx_button", 
  #       label = "Set Signer",
  #       contract_address = "0xD870A73a32d0b8C34CcF1E6098E9A26977CB605b",
  #       contract_abi = abi,
  #       contract_method = "setSigner",
  #       args = "0xa507a719e29689521B21Ccc1d68E7c8cfDBA378A",
  #       enabled = TRUE
  #   )
  # })
}

shinyApp(ui, server)