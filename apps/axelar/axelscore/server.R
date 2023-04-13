function(input, output, session) {
  
  # initialize network data, it has no selected column yet
  network.data <- reactiveValues(nodes = map.data, edges = map.connections)
  
  # initialize the active address to be an empty string
  active.addy <- reactiveValues(addy = "")
  
  # subset user data based on the active address
  thisUserData <- reactive({
    user.data[sender %in% active.addy$addy]
  })
  
  # initialize the values & create the two settings links in the right column
  settings.links <- reactiveValues(random = "see a random address",
                                   everything = "fill out the whole map")
  
  output$randomaddylink <- renderUI({
    actionLink(inputId = "randomaddy", label = settings.links$random)
  })
  
  output$everythinglink <- renderUI({
    actionLink(inputId = "everything", label = settings.links$everything)
  })
  
  # watch the random address link
  observeEvent(input$randomaddy, {
    
    # case 1 - link has not been clicked, assign a random address
    if(settings.links$random == "see a random address") {
      
      active.addy$addy <- sample(user.data$sender, round(runif(1, 1, 5)))

      
      settings.links$everything <- "fill out the whole map"
      settings.links$random <- "reset"
      
      # case 2 do the reset
    } else {
      
      active.addy$addy <- ""
      
      settings.links$everything <- "fill out the whole map"
      settings.links$random <- "see a random address"
      
    }
    
    
  })
  
  # watch the fill out everything link
  observeEvent(input$everything, {
    # case 1 - link has not been clicked, assign special fake address to fill whole map
    if(settings.links$everything == "fill out the whole map") {
      
      active.addy$addy <- "0000"
      
      settings.links$everything <- "reset"
      settings.links$random <- "see a random address"
      
      # case 2 do the reset
    } else {
      
      active.addy$addy <- ""
      
      settings.links$everything <- "fill out the whole map"
      settings.links$random <- "see a random address"
      
    }
    

  })
  
  updateNetworkData <- reactive({
    
    # if fill out the whole map is active:
    if(active.addy$addy[1] == "0000") {
      
      network.data$nodes[, selected := "yes"]
      network.data$edges[, used := "yes"]
      
    } else {
      
      visited.towns <- unique(c(thisUserData()$source_chain,
                                thisUserData()$destination_chain))
      
      used.connections <- unique(unlist(user.conns[active.addy$addy]))
      
      network.data$nodes[, selected := ifelse(station %in% visited.towns, "yes", "no")]
      network.data$edges[, used := ifelse(connection %in% used.connections, "yes", "no")]
    }
  })
  
  
  output$d3 <- renderD3({
    
    tmp <- input$randomaddy
    updateNetworkData()
    
    map.data <- reactiveValuesToList(network.data)
    
    r2d3(
      data = jsonlite::toJSON(map.data),
      script = "makemapd3.js",
      options(r2d3.theme = list(
        background = "transparent"))
    )
    
  })
  
  
  scoreSatellite <- reactive({
    max(c(min(which(sum(thisUserData()[method == "satellite"]$n_transfers) <= c(0, 1, 5, Inf))) - 1,
          min(which(sum(thisUserData()[method == "satellite"]$total_usd) <= c(0, 50, 200, Inf))) - 1))
  })
  
  bonusSatellite <- reactive({
    if(sum(thisUserData()[method == "satellite"]$n_transfers) > 10 |
       sum(thisUserData()[method == "satellite"]$total_usd) > 999) {
      1
    } else {
      0
    }
  })
  
  
  scoreSquid <- reactive({
    max(c(min(which(sum(thisUserData()[method == "squid"]$n_transfers) <= c(0, 2, 5, Inf))) - 1,
          min(which(sum(thisUserData()[method == "squid"]$total_usd) <= c(0, 50, 200, Inf))) - 1))
  })
  
  bonusSquid <- reactive({
    if(sum(thisUserData()[method == "squid"]$n_transfers) > 10 |
       sum(thisUserData()[method == "squid"]$total_usd) > 999) {
      1
    } else {
      0
    }
  })
  
  scoreUsage <- reactive({uniqueN(thisUserData()$method)})
  
  
  scorePassport <- reactive({
    uniqueN(c(thisUserData()$source_chain, thisUserData()$destination_chain)) +
      nrow(thisUserData()[source_chain %in% c("ethereum", "avalanche", "polygon", "arbitrum", "binance") & 
                            destination_chain == "osmo"]) +
      nrow(thisUserData()[destination_chain %in% c("ethereum", "avalanche", "polygon", "arbitrum", "binance") & 
                            source_chain == "osmo"])
  })
  
  
  totalScore <- reactive({scoreSatellite() + bonusSatellite() + 
      scoreSquid() + bonusSquid() + scoreUsage() +
      scorePassport()})
  
  getPersona <- reactive({
    "Cosmonaut"
  })
  
  
  output$usertotalscore <- renderText(totalScore())
  
  output$satellitescore <- renderText(scoreSatellite())
  output$satellitebonus <- renderText(paste0("+", bonusSatellite()))
  output$squidscore <- renderText(scoreSquid())
  output$squidbonus <- renderText(paste0("+", bonusSquid()))
  output$usagescore <- renderText(scoreUsage())
  output$passportscore <- renderText(scorePassport())
  
  
  getUserPersona <- reactive({
    
    chain.types <- unique(c(thisUserData()$source_chain_type, thisUserData()$destination_chain_type))
    
    if( sum(c("ibc", "evm") %in% chain.types) == 2 ) {
      #"omnivore"
      
      which.subpersona <- as.numeric(sum(thisUserData()$n_transfers) >= 5) + 1
      
      data.table(persona = c("travelling omnivore", "powerful omnivore")[which.subpersona],
                 icon1 = "globe",
                 icon2 = c("plane", "crown")[which.subpersona])
      
    } else if( sum("ibc" %in% chain.types) ) {
      "cosmonaut"
      
      which.subpersona <- max(which(sum(thisUserData()$n_transfers) >= c(0, 2, 5)))
      
      data.table(persona = c("junior cosmonaut", "wide-eyed cosmonaut", "powerful cosmonaut")[which.subpersona],
                 icon1 = "moon",
                 icon2 = c("child", "eye", "crown")[which.subpersona])
      
    } else if( sum("eth" %in% chain.types) ) {
      "ethplorer"
      
      which.subpersona <- max(which(sum(thisUserData()$n_transfers) >= c(0, 2, 5)))
      
      data.table(persona = c("junior ethplorer", "wide-eyed ethplorer", "powerful ethplorer")[which.subpersona],
                 icon1 = "map-signs",
                 icon2 = c("child", "eye", "crown")[which.subpersona])
      
    } else {
      data.table(persona = "User Persona", icon1 = "question-circle", icon2 = "question-circle")
    }
  })
  
  output$persona <- renderText(getUserPersona()$persona)
  output$personaicon1 <- renderUI(icon(getUserPersona()$icon2))
  output$personaicon2 <- renderUI(icon(getUserPersona()$icon1))
  
  
  output$clickedstation <- renderText({
    
    # Trip Summary...Avalanche...09 Visits...Last Visit: Jan 2 2009
    
    if(!is.null(input$station_clicked)) {
      if(input$station_clicked == "") {
        "Trip Summary...hover to 👀"
      } else {
        
        x <- input$station_clicked
        
        paste0("Trip Summary...",
               paste(collapse = "", rep(".", 9 - nchar(x))), x,
               "...",
               sprintf("%02.f", nrow(thisUserData()[source_chain == input$station_clicked | destination_chain == input$station_clicked])),
               " Visits...Last Visit: ",
               format(max(thisUserData()$last_transfer), format = "%b %d %Y") )
        
        
      }
    } else {
      "Trip Summary...hover to 👀"
    }
  })
  
  
  
  output$mostvisitedchain <- renderText({
    paste0("Your Most Visited Chain: ",
           rbind(thisUserData()[, .N, by = list(chain = source_chain)],
                 thisUserData()[, .N, by = list(chain = destination_chain)]) %>%
             .[, list(visits = sum(N)), by = chain] %>%
             .[order(-visits)] %>%
             .[1, chain]
    )
  })
  
  
}
