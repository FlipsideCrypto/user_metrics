function(input, output, session) {
  
  # read the connected address from the metamask connect funciton
  output$connectedaddress <- renderText(paste0("connected as: ", input$ethaddress))
  
  # isolate the data for that address so we can use it over and over
  thisAddyData <- reactive(op.metrics.w[user_address == tolower(input$ethaddress)])
  #thisAddyData <- function() op.metrics.w[user_address == tolower(input$ethaddress)]
  
  # get the airdrop score and output an empty or full star depending on achievement 
  # for the connected address
  output$airdropscore <- renderImage({
    # no address available:
    if(substr(input$ethaddress, 1, 2) != "0x") {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # score!
    } else if (thisAddyData()$airdrop_score == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
    } else {
      return(list(src = "www/star.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "⭐️"))
    }
  }, deleteFile = FALSE)
  
  # repeat ^ for the other 4 scores:
  output$nftscore <- renderImage({
    # no address available:
    if(substr(input$ethaddress, 1, 2) != "0x") {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
    } else if (thisAddyData()$nft_score == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # score!
    } else {
      return(list(src = "www/star.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "⭐️"))
    }
  }, deleteFile = FALSE)
  
  output$delegatescore <- renderImage({
    # no address available:
    if(substr(input$ethaddress, 1, 2) != "0x") {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
    } else if (thisAddyData()$delegation_score == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # score!
    } else {
      return(list(src = "www/star.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "⭐️"))
    }
  }, deleteFile = FALSE)
  
  output$cexscore <- renderImage({
    # no address available:
    if(substr(input$ethaddress, 1, 2) != "0x") {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
    } else if (thisAddyData()$cex_score == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # score!
    } else {
      return(list(src = "www/star.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "⭐️"))
    }
  }, deleteFile = FALSE)
  
  output$dexscore <- renderImage({
    # no address available:
    if(substr(input$ethaddress, 1, 2) != "0x") {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # does not score or no data available
    } else if (nrow(thisAddyData()) == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
    } else if (thisAddyData()$dex_score == 0) {
      return(list(src = "www/emptystar.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "X"))
      # score!
    } else {
      return(list(src = "www/star.svg", contentType = 'image/svg+xml', height = 30, width = 30, alt = "⭐️"))
    }
  }, deleteFile = FALSE)
  
  
  
  output$totalscore <- renderText({
    
    
    if(substr(input$ethaddress, 1, 2) != "0x") {
      
      "Connect to get your Optimist Score"
      
    } else if(nrow(thisAddyData()) == 0) {
      
      
      "Your a Zero Star Optimist :-( Maybe buy an nft? or delegate some OP?"
      
    } else {
      
      paste("You're a ", paste(rep("⭐️", thisAddyData()$total_score), collapse = ""), " Optimist")
      
    }
    
  })
  
}

