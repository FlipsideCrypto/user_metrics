function(input, output, session) {
  
  # read the connected address from the metamask connect function
  # output$connectedaddress <- renderText(paste0("connected as: ", input$eth_address))
  
  # isolate the data for that address so we can use it over and over
  thisAddyData <- reactive({
    
    print("connectpop:")
    print(input$connectpop)
    print("connect:")
    print(input$connect)
    print("address")
    print(input$eth_address)
    op.metrics.w[user_address == tolower(input$eth_address)]
    })
  
  observeEvent(input$eth_address, {
    if(substr(input$eth_address, 1, 2) == "0x") {
      updateActionButton(session = session, inputId = "connect", 
                         label = paste0("connected as ", substr(input$eth_address, 1, 7), "..."),
                         icon = character(0))
      tmp <- data.table(address = input$eth_address,
                        time = Sys.time(),
                        score = userScore())
      write.csv(tmp, file = paste0("/rstudio-data/optimistic-data/", input$eth_address, "_", Sys.time(), ".csv"), row.names = FALSE)
      
    } else {
      
      updateActionButton(session = session, inputId = "connect", 
                         icon = icon("wallet"), label = "  Connect Wallet")
    }
  })
  
  output$connectedaddress <- renderText({
    if(substr(input$eth_address, 1, 2) == "0x") {
      paste0("Connected as ", substr(input$eth_address, 1, 10), "...")
    } else {
      ""
    }
  })
  
  # get the airdrop score and output an empty or full button_filled depending on achievement 
  # for the connected address
  output$airdropscore <- renderText({
    # no address available:
    if(substr(input$eth_address, 1, 2) != "0x") {
      return(0)
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(0)
      # score!
    } else if (thisAddyData()$airdrop_score == 0) {
      return(0)
    } else {
      return(1)
    }
  })
  
  # repeat ^ for the other 4 scores:
  output$nftscore <- renderText({
    # no address available:
    if(substr(input$eth_address, 1, 2) != "0x") {
      return(0)
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(0)
    } else if (thisAddyData()$nft_score == 0) {
      return(0)
      # score!
    } else {
      return(1)
    }
  })
  
  output$delegatescore <- renderText({
    # no address available:
    if(substr(input$eth_address, 1, 2) != "0x") {
      return(0)
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(0)
    } else if (thisAddyData()$delegation_score == 0) {
      return(0)
      # score!
    } else {
      return(1)
    }
  })
  
  output$cexscore <- renderText({
    # no address available:
    if(substr(input$eth_address, 1, 2) != "0x") {
      return(0)
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(1)
    } else if (thisAddyData()$cex_score == 0) {
      return(1)
      # score!
    } else {
      return(1)
    }
  })
  
  output$dexscore <- renderText({
    # no address available:
    if(substr(input$eth_address, 1, 2) != "0x") {
      return(0)
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(0)
    } else if (thisAddyData()$dex_score == 0) {
      return(0)
      # score!
    } else {
      return(1)
    }
  })
  
  
  output$totalscore <- renderText({
    ifelse(substr(input$eth_address, 1, 2) == "0x", userScore(), 0)
  })

  
  
  userScore <- reactive({
    if(nrow(thisAddyData()) > 0) {
      thisAddyData()$total_score
    } else {
      1
    }
  })
  
  
  
  
  output$tx_handler <- renderUI({
    TransactionHandler(
      "tx_button", 
      chainId = 10,
      label = "Attest Your Score On Chain",
      contract_address = "0xD870A73a32d0b8C34CcF1E6098E9A26977CB605b",
      contract_abi = abi,
      contract_method = "attest",
      provider = provider,
      args = c(input$eth_address, "Flipside_user_scoring", userScore()),
      enabled = TRUE
    )
  })
  
  
}

