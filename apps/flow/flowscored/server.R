function(input, output, session) {
  

  n.users <- nrow(flowscored.metrics.w)
  
  thisUser_nft_n_trades <- reactive(flowscored.metrics.w[user_address == input$addy]$nft_n_trades)
  output$nft_n_trades <- renderText(thisUser_nft_n_trades())
  output$nft_n_trades_p <- renderText(round(nrow(flowscored.metrics.w[nft_n_trades < thisUser_nft_n_trades()])/n.users, 2))
  
  thisUser_days_since_last_tx <- reactive(flowscored.metrics.w[user_address == input$addy]$days_since_last_tx)
  output$days_since_last_tx <- renderText(thisUser_days_since_last_tx())
  output$days_since_last_tx_p <- renderText(round(nrow(flowscored.metrics.w[days_since_last_tx < thisUser_days_since_last_tx()])/n.users, 2))
  
  thisUser_nft_n_projects <- reactive(flowscored.metrics.w[user_address == input$addy]$nft_n_projects)
  output$nft_n_projects <- renderText(thisUser_nft_n_projects())
  output$nft_n_projects_p <- renderText(round(nrow(flowscored.metrics.w[nft_n_projects < thisUser_nft_n_projects()])/n.users, 2))
  
  thisUser_nft_n_listings <- reactive(flowscored.metrics.w[user_address == input$addy]$nft_n_listings)
  output$nft_n_listings <- renderText(thisUser_nft_n_listings())
  output$nft_n_listings_p <- renderText(round(nrow(flowscored.metrics.w[nft_n_listings < thisUser_nft_n_listings()])/n.users, 2))
  
  
  output$award_flowty_list <- renderText({
    if(flowscored.metrics.w[user_address == input$addy]$flowty_list) {
      "🏆"
    } else {
      "❌"
    }
  })
  
  output$award_hodl_only <- renderText({
    if(flowscored.metrics.w[user_address == input$addy]$flowty_list) {
      "🏆"
    } else {
      "❌"
    }
  })

  output$award_own_flovatar <- renderText({
    if(flowscored.metrics.w[user_address == input$addy]$flowty_list) {
      "🏆"
    } else {
      "❌"
    }
  })

  output$award_dex_swapper <- renderText({
    if(flowscored.metrics.w[user_address == input$addy]$dex_swapper) {
      "🏆"
    } else {
      "❌"
    }
  })

  output$award_positive_trader <- renderText({
    if(flowscored.metrics.w[user_address == input$addy]$positive_trader) {
      "🏆"
    } else {
      "❌"
    }
  })

  output$badge_topshot_trader <- renderText({
    if(flowscored.metrics.w[user_address == input$addy]$top_topshot_trader == 1) {
      "🏆"
    } else {
      "❌"
    }
  })
  
  
}
