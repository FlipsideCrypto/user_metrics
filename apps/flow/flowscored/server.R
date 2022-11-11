function(input, output, session) {
  
  output$inputaddy <- renderUI({
    textInput(inputId = "addy", label = "Enter Your Address", value = "0x9244cd25314edd34")
  })
  
  
  observeEvent(input$dapperconnect, {
    showModal(modalDialog(
      title = "Connect to Your Dapper Wallet",
      "do you want to be Jack F, Jack F or Angeal?",
      selectizeInput("dapperaddy", label = "NULL",
                           choices = c("Jack F", "Other Jack F", "Angeal"), selected = input$dapperaddy)
    ))
  })
  
  #https://community.rstudio.com/t/persistent-selected-values-using-modal-selectinput/7160/2
  observeEvent(input$bloctoconnect, {
    showModal(modalDialog(
      title = "Connect to Your Blocto Wallet",
      "coming soon..."
      ))
  })
  
  
  jackf1 <- c("0x69a1f5cefd1e0fdf", "0xcf3ead0e195bdd0f")
  angeal <- c("0xc04f0af1dab0a999", "0x52eceb884aa542c6")
  jackf2 <- c("0xcc17b1ed3d9b079c", "0x60787d9233b782ad")
  
  userAddys <- reactive({
    if(input$dapperaddy == "Jack F") {
      jackf1
    } else if(input$dapperaddy == "Other Jack F") {
      jackf2
    } else {
      angeal
    }
  })
  
  n.users <- nrow(flowscored.metrics.w)
  
  thisUser_nft_n_trades <- reactive( sum(flowscored.metrics.w[user_address %in% userAddys()]$nft_n_trades) )
  output$nft_n_trades <- renderText(thisUser_nft_n_trades())
  output$nft_n_trades_p <- renderText(round(nrow(flowscored.metrics.w[nft_n_trades < thisUser_nft_n_trades()])/n.users, 2))
  
  thisUser_days_since_last_tx <- reactive( sum(flowscored.metrics.w[user_address %in% userAddys()]$days_since_last_tx) )
  output$days_since_last_tx <- renderText(thisUser_days_since_last_tx())
  output$days_since_last_tx_p <- renderText(round(nrow(flowscored.metrics.w[days_since_last_tx < thisUser_days_since_last_tx()])/n.users, 2))
  
  thisUser_nft_n_projects <- reactive( sum(flowscored.metrics.w[user_address %in% userAddys()]$nft_n_projects) )
  output$nft_n_projects <- renderText(thisUser_nft_n_projects())
  output$nft_n_projects_p <- renderText(round(nrow(flowscored.metrics.w[nft_n_projects < thisUser_nft_n_projects()])/n.users, 2))
  
  thisUser_nft_n_listings <- reactive( sum(flowscored.metrics.w[user_address %in% userAddys()]$nft_n_listings) )
  output$nft_n_listings <- renderText(thisUser_nft_n_listings())
  output$nft_n_listings_p <- renderText(round(nrow(flowscored.metrics.w[nft_n_listings < thisUser_nft_n_listings()])/n.users, 2))
  
  
  
  output$action_listed_nft <- renderText({
    if( sum(flowscored.metrics.w[user_address %in% userAddys()]$list_nft) > 0 ) {
      "🏆"
    } else {
      "❌"
    }
  })
  
  output$action_bought_nfts <- renderText({
    if( sum(flowscored.metrics.w[user_address %in% userAddys()]$list_nft) > 0 ) {
      "🏆"
    } else {
      "❌"
    }
  })

  output$action_staked_flow <- renderText({
    if( sum(flowscored.metrics.w[user_address %in% userAddys()]$staked_flow) > 0 ) {
      "🏆"
    } else {
      "❌"
    }
  })

  output$action_dex_swap <- renderText({
    if( sum(flowscored.metrics.w[user_address %in% userAddys()]$dex_swapper) > 0 ) {
      "🏆"
    } else {
      "❌"
    }
  })

  # output$award_positive_trader <- renderText({
  #   if(flowscored.metrics.w[user_address %in% userAddys()]$positive_trader) {
  #     "🏆"
  #   } else {
  #     "❌"
  #   }
  # })
  # 
  # output$badge_topshot_trader <- renderText({
  #   if(flowscored.metrics.w[user_address %in% userAddys()]$top_topshot_trader == 1) {
  #     "🏆"
  #   } else {
  #     "❌"
  #   }
  # })
  # 
  
}
