function(input, output, session) {
  
  observeEvent(input$randomaddy, {
    
    new.addys <- dual.address.set[sample(1:nrow(dual.address.set), 1)]
    
    updateTextInput(session = session, "dapperaddy", value = new.addys$dapper)
    updateTextInput(session, "bloctoaddy", value = new.addys$blocto)
    
  }, suspended = F)
  
  
  output$dapperaddyO <- renderUI({
    textInput(inputId = "dapperaddy", label = NULL, value = "0xc04f0af1dab0a999")
  })
  
  output$bloctoaddyO <- renderUI({
    textInput(inputId = "bloctoaddy", label = NULL, value = "0x52eceb884aa542c6")
  })
  
  userData <- reactive({
    user.stats[user_address %in% c(input$dapperaddy, input$bloctoaddy)]
  })
  
  ripScore <- reactive(c(0, 1,2,3)[max(which(sum(userData()$n_rips) >= c(0, 1,5,10)))])
  listingScore <- reactive(c(0, 1,2,3)[max(which(sum(userData()$n_listings) >= c(0, 1,5,10)))])
  dapperBuysScore <- reactive(c(0, 1,2,3)[max(which(sum(userData()$n_nft_buys_dapper) >= c(0, 1,5,10)))])
  nonDapperTradesScore <- reactive(c(0, 1)[max(which(sum(userData()$n_nft_trades_nd) >= c(0, 1)))])
  stakesScore <- reactive( c(0, 1)[max(which(sum(userData()$n_stakes) >= c(0, 1)))])
  swapsScore <- reactive(c(0, 1)[max(which(sum(userData()$n_swaps) >= c(0, 1)))])
  totalScore <- reactive(ripScore() + listingScore() + dapperBuysScore() + nonDapperTradesScore() + stakesScore() + swapsScore())
  
  
  output$totalscore <- renderText(totalScore())
  
  
  output$dapper1 <- renderText(ripScore())
  output$dapper1text <- renderText(paste0(sum(userData()$n_rips), " pack rips"))
  
  output$dapper2 <- renderText(listingScore())
  output$dapper2text <- renderText(paste0(sum(userData()$n_listings), " listings"))
  
  output$dapper3 <- renderText(dapperBuysScore())
  output$dapper3text <- renderText(paste0(sum(userData()$n_nft_buys_dapper), " marketplace buys"))
  
  output$bonus1 <- renderText(nonDapperTradesScore())
  output$bonus1text <- renderText(paste0(sum(userData()$n_nft_trades_nd), " non-Dapper NFT trades"))
  
  output$bonus2 <- renderText(stakesScore())
  output$bonus2text <- renderText(paste0(sum(userData()$n_stakes), " FLOW stakes"))
  
  output$bonus3 <- renderText(swapsScore())
  output$bonus3text <- renderText(paste0(sum(userData()$n_swaps), " dex swaps"))
  
  
  
  
}
