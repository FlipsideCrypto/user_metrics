function(input, output, session) {
  
  inputToAddy <- reactive({
    
    if(!is.null(input$my_wallet)) {
      if(input$my_wallet[1] != "") {
        rbindlist(lapply(strsplit(input$my_wallet, ":"), function(x) {
          data.table(wallet_name = ifelse(x[1] == "dapper", "dapper", "non-dapper"), user_address = x[2])
        }))
      } else {
        data.table()
      }
    } else {
      data.table()
    }
    
  })
  
  userData <- reactive({
    
    if(nrow(inputToAddy()) > 0) {
      
      tmp <- user.stats[user_address %in% inputToAddy()$user_address]
      
      if(nrow(tmp) > 0) {
        tmp
      } else {
        data.table(user_address = "", n_rips = 0, n_listings = 0, n_nft_buys_dapper = 0,
                   n_nft_trades_nd = 0, n_nft_projects_nf = 0, n_stakes = 0, n_swaps = 0)
      }
    }
    
  })
  
  ripScore <- reactive(c(0, 1,2,3)[max(which(sum(userData()$n_rips) >= c(0, 1,5,10)))])
  listingScore <- reactive(c(0, 1,2,3)[max(which(sum(userData()$n_listings) >= c(0, 1,5,10)))])
  dapperBuysScore <- reactive(c(0, 1,2,3)[max(which(sum(userData()$n_nft_buys_dapper) >= c(0, 1,5,10)))])
  nonDapperTradesScore <- reactive(c(0, 1)[max(which(sum(userData()$n_nft_trades_nd) >= c(0, 1)))])
  stakesScore <- reactive( c(0, 1)[max(which(sum(userData()$n_stakes) >= c(0, 1)))])
  swapsScore <- reactive(c(0, 1)[max(which(sum(userData()$n_swaps) >= c(0, 1)))])
  totalScore <- reactive(ripScore() + listingScore() + dapperBuysScore() + nonDapperTradesScore() + stakesScore() + swapsScore())
  
  
  # use this to decide which row of the spreadsheet applies to this user:
  userLinkRecord <- reactive({
    
    if(nrow(inputToAddy()) > 0) {
      # if any wallet is connected:
      fill.box[max(which(fill.box$score_min <= totalScore()))]
    } else {
      # if no wallet is connected:
      fill.box[score_min == "disconnected"]
    }
  })
  
  
  output$rightlink <- renderUI({
    # step 0 - get the data from the secret spreadsheet
    link.criteria <- userLinkRecord()
    print(link.criteria)
    
    if(link.criteria$right_addy_type == "NA") {
      # if we have no connected address OR there is no addy type, just output the link
      
      tagList(a(class = "promptlinks", href = link.criteria$right_link, link.criteria$right_text,
                target = "_blank",
                onclick = "rudderstack.track('flowscored-click-right-promo')"))
      
    } else {
      
      addy.type <- link.criteria$right_addy_type
      
      if(addy.type %in% inputToAddy()$wallet_name) {
        
      # step 1 - get the right address from 
      if(link.criteria$right_addy_type == "non-dapper") {
        right.addy <- inputToAddy()[wallet_name != 'dapper']$user_address[1]
      } else {
        right.addy <- inputToAddy()[wallet_name == 'dapper']$user_address[1]
      }
      
      # step 2 - get the token encoding for the address
      encryptlink <- readLines("encryptlink")[1]
      right.addy.token <- fromJSON(readLines(paste0(encryptlink, right.addy)))
      right.addy.token <- paste0("/?token=", right.addy.token)
      
      # step 3 - add that token encoding to the link
      full.right.link <- paste0(link.criteria$right_link, right.addy.token)
      
      # step 4 - output the link
      tagList(a(class = "promptlinks", href = full.right.link, link.criteria$right_text,
                target = "_blank",
                onclick = "rudderstack.track('flowscored-click-right-promo')"))
      
      } else {
        actionLink(inputId = "right_no_wallet", label = link.criteria$right_text)
      }
    }
  })
  
  observeEvent(input$right_no_wallet, {
    showModal(modalDialog(
      title = "",
      "Connect a non-dapper wallet to access this promo!",
      footer = modalButton("close")
    ))
    
  })
  
  output$leftlink <- renderUI({
    
    # step 0 - get the data from the secret spreadsheet
    link.criteria <- userLinkRecord()
    
    if(link.criteria$left_addy_type == "NA") {
      # if we have no connected address OR there is no addy type, just output the link
      tagList(a(class = "promptlinks", href = link.criteria$left_link, link.criteria$left_text,
                target = "_blank",
                onclick = "rudderstack.track('flowscored-click-left-promo')"))
      
    } else {
      
      addy.type <- link.criteria$left_addy_type
      
      print(addy.type)
      print(inputToAddy())
      
      if(addy.type %in% inputToAddy()$wallet_name) {
        
        # step 1 - get the left address from 
        if(link.criteria$left_addy_type == "non-dapper") {
          left.addy <- inputToAddy()[wallet_name != 'dapper']$user_address[1]
        } else {
          left.addy <- inputToAddy()[wallet_name == 'dapper']$user_address[1]
        }
        
        # step 2 - get the token encoding for the address
        encryptlink <- readLines("encryptlink")[1]
        left.addy.token <- fromJSON(readLines(paste0(encryptlink, left.addy)))
        left.addy.token <- paste0("/?token=", left.addy.token)
        
        # step 3 - add that token encoding to the link
        full.left.link <- paste0(link.criteria$left_link, left.addy.token)
        
        # step 4 - output the link
        tagList(a(class = "promptlinks", href = full.left.link, link.criteria$left_text,
                  target = "_blank",
                  onclick = "rudderstack.track('flowscored-click-left-promo')"))
        
      } else {
        
        actionLink(inputId = "left_no_wallet", label = link.criteria$left_text)
        
      }
      
    }
    
  })
  
  observeEvent(input$left_no_wallet, {
    showModal(modalDialog(
      title = "",
      "Connect a non-dapper wallet to access this promo!",
      footer = modalButton("close")
    ))
  })
  
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
