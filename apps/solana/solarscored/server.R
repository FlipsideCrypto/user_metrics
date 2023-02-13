function(input, output, session) {
  
  connected.addy <- reactiveValues(addy = "connect wallet")
  
  #observeEvent("sol_address")
  
  # output$useraddy <- renderUI({
  #   textInput("addy", "SOURCE ADDRESS:", value = connected.addy$addy)
  # })
  
  
  userRecord <- reactive({
    if(!is.null(input$addy)) {
      
      if(nchar(input$addy) > 0) {
        
        df[user_address == input$addy]
        
      } else {
        empty.df
      }
    } else {
      empty.df
    }
  })
  
  observeEvent(input$sol_address, {
    print(input$sol_address)
    if(input$sol_address != "") {
      
      connected.addy$addy <- input$sol_address
      
      # updateActionButton(session = session, inputId = "connect", 
      #                    label = paste0("connected as ", substr(input$sol_address, 1, 7), "..."),
      #                    icon = character(0))
      # tmp <- data.table(address = input$sol_address,
      #                   time = Sys.time(),
      #                   score = userScore())
      # write.csv(tmp, file = paste0("/rstudio-data/optimistic-data/", input$eth_address, "_", Sys.time(), ".csv"), row.names = FALSE)
      
    } else {
      
      # updateActionButton(session = session, inputId = "connect", 
      #                    icon = icon("wallet"), label = "  Connect Wallet")
    }
  })
  
  svgColored <- reactive({
    
    new.svg <- svgdata
    
    if(!is.null(input$addy)) {
      
      if(nchar(input$addy) > 0 & input$addy != "connect wallet") {
        
        new.style <- c()
        
        for(i in 1:7) {
          tmp <- userRecord()[[categories[i]]]
           new.style <- c(new.style, c(rep(1, tmp), rep(0, (3-tmp))))
        }
        
        for(i in 1:21) {
          new.svg <- str_replace(string = new.svg, pattern = "%s", replacement = ifelse(new.style[i] == 1, "100%", "20%"))
        }
        
      } else {
        for(i in 1:21) {
          new.svg <- str_replace(string = new.svg, pattern = "%s", replacement = base.style[i])
        }
      }
      
    } else {
      for(i in 1:21) {
        new.svg <- str_replace(string = new.svg, pattern = "%s", replacement = base.style[i])
      }
    }
    
    new.svg
    
  }
  )
  
  
  output$svgout <- renderUI({
    HTML(svgColored())
  })
  
  observeEvent(input$randomaddy, {
    updateTextInput(session, "addy", value = sample(df$user_address, 1))
  }, suspended = F)
  
  
  
  output$outputslider <- renderUI({
    sliderTextInput(
      inputId = "scoreslider",
      label = NULL,
      choices = 1:21,
      selected = c(5, 15),
      grid = TRUE,
      width = "100%"
    )
  })
  
  output$scorehist <- renderPlotly({
    
    if(length(input$scoreslider) > 0) {
      active.scores <- input$scoreslider[1]:input$scoreslider[2]
    } else {
      active.scores <- 5:15    
    }
    
    to.plot <- rbind(
      data.table(total_score = 1:5, N = 0),
      df[, .N, by = total_score][order(total_score)], 
      data.table(total_score = 19:21, N = 0)
    )
    to.plot[, bar_color := ifelse(total_score %in% active.scores, bar.plot.colors[1], bar.plot.colors[2])]
    
    plot_ly(to.plot, 
            x = ~total_score, y = ~N, type = 'bar', 
            marker = list(color = to.plot$bar_color)) %>%
      layout(bargap = 0.2,
             xaxis = list(title = "",
                          showticklabels = FALSE,
                          showgrid = FALSE,
                          fixedrange = TRUE),
             yaxis = list(title = "",
                          showticklabels = FALSE,
                          showgrid = FALSE,
                          fixedrange = TRUE,
                          type = "log"),
             showlegend = FALSE,
             margin = list(l=6, r=6, b=0, t=0, autoexpand = FALSE),
             plot_bgcolor = "transparent",
             paper_bgcolor = "transparent") %>%
      config(displayModeBar = FALSE,
             showLink = FALSE)
    
  })
  
  output$bdnldscores <- renderUI({
    
    tmp.label <- paste("Get Scores for ", 
                       format(nrow(df[total_score >= input$scoreslider[1] & total_score <= input$scoreslider[2]]), big.mark = ","),
                       " Users")
    
    downloadButton(outputId = 'download_scores_metrics',
                   label = tmp.label,
                   icon = NULL)
    
  })
  
  output$download_scores_metrics <- downloadHandler(
    filename = function() {
      paste('scores_', input$scoreslider[1], '_to_', input$scoreslider[2], '_', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      to.download <- df[total_score >= input$scoreslider[1] & total_score <= input$scoreslider[2]]
      write.csv(to.download, file)
    }
  )
  
  output$userscore <- renderText({
    userRecord()$total_score
  })
  
  output$useractivity <- renderText({
    round(userRecord()[["activity_value"]])
  })
  output$usernfts <- renderText({
    round(userRecord()[["nft_value"]])
  })
  output$userlongevity <- renderText({
    round(userRecord()[["longevity_value"]])
  })
  output$uservariety <- renderText({
    round(userRecord()[["variety_value"]])
  })
  output$userstaking <- renderText({
    round(userRecord()[["staking_value"]])
  })
  output$userbridge <- renderText({
    round(userRecord()[["bridge_value"]])
  })
  output$usergovernance <- renderText({
    round(userRecord()[["governance_value"]])
  })
  
  
  
  
}

