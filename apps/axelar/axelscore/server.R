function(input, output, session) {
  
  # initialize network data, it has no selected column yet
  network.data <- reactiveValues(nodes = map.data, edges = map.connections)
  
  # initialize the active address to be an empty string
  active.addy <- reactiveValues(map_addy = "",
                                score_addy = "")
  
  
  # initialize the values & create the two settings links in the right column
  settings.links <- reactiveValues(random = "map a random address",
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
    if(settings.links$random == "map a random address") {
      
      active.addy$map_addy <- sample(user.data$sender, round(runif(1, 1, 5)))
      
      settings.links$everything <- "fill out the whole map"
      settings.links$random <- "reset"
      
      # case 2 do the reset
    } else {
      
      if(!is.null(input$my_wallet)) {
        if(input$my_wallet != "") {
          active.addy$map_addy <- inputToAddy()$address
          active.addy$score_addy <- inputToAddy()$address
        } else {
          active.addy$map_addy <- ""
        }
      } else {
        active.addy$map_addy <- ""
      }
      
      settings.links$everything <- "fill out the whole map"
      settings.links$random <- "map a random address"
      
    }
    
    
  })
  
  
  # watch the fill out everything link
  observeEvent(input$everything, {
    # case 1 - link has not been clicked, assign special fake address to fill whole map
    if(settings.links$everything == "fill out the whole map") {
      
      active.addy$map_addy <- "0000"
      
      settings.links$everything <- "reset"
      settings.links$random <- "map a random address"
      
      # case 2 do the reset
    } else {
      
      if(!is.null(input$my_wallet)) {
        if(input$my_wallet != "") {
          active.addy$map_addy <- inputToAddy()$address
          active.addy$score_addy <- inputToAddy()$address
        } else {
          active.addy$map_addy <- ""
        }
      } else {
        active.addy$map_addy <- ""
      }
      
      settings.links$everything <- "fill out the whole map"
      settings.links$random <- "map a random address"
      
    }
    
    
  })
  
  inputToAddy <- reactive({
    
    if(!is.null(input$my_wallet)) {
      if(input$my_wallet[1] != "") {
        
        split.addys <- strsplit(strsplit(input$my_wallet, ",")[[1]], ":")
        
        rbindlist(lapply(split.addys, function(addy) {
          
          data.table(chain = addy[1], 
                     address = tolower(addy[2]), 
                     addy_type = ifelse(substr(addy[2], 1, 2) == "0x", "evm", substr(addy[1], 1, 4))
          )
          
        }))
        
      } else {
        data.table()
      }
    } else {
      data.table()
    }
    
  })
  
  observeEvent(input$my_wallet, {
    if(!is.null(input$my_wallet)) {
      if(input$my_wallet != "") {
        active.addy$map_addy <- inputToAddy()$address
        active.addy$score_addy <- inputToAddy()$address
        
        settings.links$everything <- "fill out the whole map"
        settings.links$random <- "map a random address"
        
      }
    }
  })
  
  # subset user data based on the active address
  thisUserMapData <- reactive({
    user.data[sender %in% active.addy$map_addy]
  })
  
  thisUserScoreData <- reactive({
    user.data[sender %in% active.addy$score_addy]
  })
  
  
  updateNetworkData <- reactive({
    
    # if fill out the whole map is active:
    if(active.addy$map_addy[1] == "0000") {
      
      network.data$nodes[, selected := "yes"]
      network.data$edges[, used := "yes"]
      
    } else {
      
      visited.towns <- unique(c(thisUserMapData()$source_chain,
                                thisUserMapData()$destination_chain))
      
      used.connections <- unique(unlist(
        
        user.conns[active.addy$map_addy]
        
      ))
      
      network.data$nodes[, selected := ifelse(station %in% visited.towns, "yes", "no")]
      network.data$edges[, used := ifelse(connection %in% used.connections, "yes", "no")]
    }
    
  })
  
  
  output$d3 <- renderD3({
    
    tmp <- input$randomaddy
    tmp <- input$my_wallet
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
    max(c(min(which(sum(thisUserScoreData()[method == "satellite"]$n_transfers) <= c(0, 1, 5, Inf))) - 1,
          min(which(sum(thisUserScoreData()[method == "satellite"]$total_usd) <= c(0, 50, 200, Inf))) - 1))
  })
  
  bonusSatellite <- reactive({
    if(sum(thisUserScoreData()[method == "satellite"]$n_transfers) > 10 |
       sum(thisUserScoreData()[method == "satellite"]$total_usd) > 999) {
      1
    } else {
      0
    }
  })
  
  
  scoreSquid <- reactive({
    max(c(min(which(sum(thisUserScoreData()[method == "squid"]$n_transfers) <= c(0, 2, 5, Inf))) - 1,
          min(which(sum(thisUserScoreData()[method == "squid"]$total_usd) <= c(0, 50, 200, Inf))) - 1))
  })
  
  bonusSquid <- reactive({
    if(sum(thisUserScoreData()[method == "squid"]$n_transfers) > 10 |
       sum(thisUserScoreData()[method == "squid"]$total_usd) > 999) {
      1
    } else {
      0
    }
  })
  
  scoreUsage <- reactive({uniqueN(thisUserScoreData()$method)})
  
  
  scorePassport <- reactive({
    uniqueN(c(thisUserScoreData()$source_chain, thisUserScoreData()$destination_chain))
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
    
    chain.types <- unique(c(thisUserScoreData()$source_chain_type, thisUserScoreData()$destination_chain_type))
    
    if( sum(c("ibc", "evm") %in% chain.types) == 2 ) {
      #"omnivore"
      
      which.subpersona <- as.numeric(sum(thisUserScoreData()$n_transfers) >= 5) + 1
      
      data.table(persona = c("travelling omnivore", "powerful omnivore")[which.subpersona],
                 icon1 = "globe",
                 icon2 = c("plane", "crown")[which.subpersona])
      
    } else if( sum("ibc" %in% chain.types) ) {
      "cosmonaut"
      
      which.subpersona <- max(which(sum(thisUserScoreData()$n_transfers) >= c(0, 2, 5)))
      
      data.table(persona = c("junior cosmonaut", "wide-eyed cosmonaut", "powerful cosmonaut")[which.subpersona],
                 icon1 = "moon",
                 icon2 = c("child", "eye", "crown")[which.subpersona])
      
    } else if( sum("eth" %in% chain.types) ) {
      "ethplorer"
      
      which.subpersona <- max(which(sum(thisUserScoreData()$n_transfers) >= c(0, 2, 5)))
      
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
               paste(collapse = "", rep(".", 12 - nchar(x))), x,
               "...",
               sprintf("%02.f", nrow(thisUserMapData()[source_chain == input$station_clicked | destination_chain == input$station_clicked])),
               " Visits"
               # " Visits...Last Visit: ",
               # format(max(thisUserMapData()$last_transfer), format = "%b %d %Y") 
        )
        
        
      }
    } else {
      "Trip Summary...hover to 👀"
    }
  })
  
  
  
  output$mostvisitedchain <- renderText({
    simpleCap(paste0("Your Most Visited Chain: ",
           rbind(thisUserScoreData()[, .N, by = list(chain = source_chain)],
                 thisUserScoreData()[, .N, by = list(chain = destination_chain)]) %>%
             .[, list(visits = sum(N)), by = chain] %>%
             .[order(-visits)] %>%
             .[1, chain])
    )
  })
  
  output$promotitle <- renderText({
    
    if(!is.null(input$my_wallet)) {
      if(input$my_wallet != "") {
        "Your Deals - Click to Claim!"
      } else {
        "!! Special Promo 4 U !! Connect to 👁"
      }
    } else {
      "!! Special Promo 4 U !! Connect to 👁"
    }
  })
  
  # ok decide the promos here!
  userPromo1 <- reactive({
    # step 0: figure out which promo the user qualifies for
    # current criteria:
    # 1 unconnected
    # 2 satellite only - learn to use squid
    # 3 squid only - learn to use satellite
    # 3 both - level up your squid game
    
    methods.used <- unique(thisUserScoreData()$method)
    
    if(nrow(inputToAddy()) == 0) {
      user.promo1 <- 1
    } else if(length(methods.used) == 2) {
      user.promo1 <- 4
    } else if(length(methods.used) == 0) {
      user.promo1 <- 2
    } else if(methods.used == "satellite") {
      user.promo1 <- 2
    } else {
      user.promo1 <- 3
    }
    
    user.promo1
  })
  
  output$promo1 <- renderUI({
    
    if(userPromo1() == 1) {
      # if we have no connected address OR there is no addy type, just output the link
      
      # tagList(a(class = "promptlinks",
      #           href = promo.criteria[userPromo1()]$promo_link,
      #           promo.criteria[userPromo1()]$promo_title,
      #           target = "_blank",
      #           onclick = "rudderanalytics.track('axelscore-click-promo1')"))
      
      div(class = "hiddenpromo1", "?")
      
    } else {
      
      pay.addy.type <- promo.criteria[userPromo1()]$payment_address_type
      use.addy.type <- promo.criteria[userPromo1()]$bounty_address_type
      
      if(pay.addy.type %in% inputToAddy()$addy_type & use.addy.type %in% inputToAddy()$addy_type) {
        
        user.addy.promo1 <- inputToAddy()[addy_type == pay.addy.type]$address
        
        # step 2 - get the token encoding for the address
        encryptlink <- readLines("encryptlink")[1]
        promo1.token <- fromJSON(readLines(paste0(encryptlink, user.addy.promo1)))
        promo1.token <- paste0("/?token=", promo1.token)
        
        # step 3 - add that token encoding to the link
        promo1.full.link <- paste0(promo.criteria[userPromo1()]$promo_link, promo1.token)
        
        # step 4 - output the link
        tagList(div(class = "promo", 
                    a(class = "promptlinks",
                      href = promo1.full.link,
                      promo.criteria[userPromo1()]$promo_title,
                      target = "_blank",
                      onclick = "rudderanalytics.track('axelscore-click-promo1')")))
        
      } else {
        actionLink(inputId = "promo1_no_wallet", label = promo.criteria[userPromo1()]$promo_title)
      }
    }
  })
  
  observeEvent(input$promo1_no_wallet, {
    
    wallet.types <- data.table(wallet_type = c("evm", "axelar", "osmosis"),
                               abbr = c("evm", "axel", "osmo"))
    
    types.needed <- unlist(promo.criteria[userPromo1(), list(payment_address_type, bounty_address_type)])
    
    modal.text <- paste0("Please connect the following wallet types to claim this promo: ", 
                         paste(types.needed[!(types.needed %in% inputToAddy()$addy_type)], collapse = ", "))
    
    showModal(modalDialog(
      title = "",
      modal.text,
      footer = modalButton("close")
    ))
  })
  
  # do it again for 2!!!
  
  # ok decide the promos here!
  userPromo2 <- reactive({
    # step 0: figure out which promo the user qualifies for
    # current criteria:
    # 4 unconnected or score < 5
    # 5 connected score 6 to 9
    # 6 connected score 10+
    
    if(nrow(inputToAddy()) == 0) {
      user.promo2 <- 0
    } else if (totalScore() < 5) {
      user.promo2 <- 5
    } else if(totalScore() >= 5 & totalScore() < 10) {
      user.promo2 <- 6
    } else  {
      user.promo2 <- 7
    }
    
    user.promo2
  })
  
  output$promo2 <- renderUI({
    
    if(userPromo2() == 0) {
      # if we have no connected address OR there is no addy type, just output the link
      
      # tagList(a(class = "promptlinks",
      #           href = promo.criteria[userPromo2()]$promo_link,
      #           promo.criteria[userPromo2()]$promo_title,
      #           target = "_blank",
      #           onclick = "rudderanalytics.track('axelscore-click-promo2')"))
      
      div(class = "hiddenpromo2", "?")
      
    } else {
      
      pay.addy.type <- promo.criteria[userPromo2()]$payment_address_type
      use.addy.type <- promo.criteria[userPromo2()]$bounty_address_type
      
      if(pay.addy.type %in% inputToAddy()$addy_type & use.addy.type %in% inputToAddy()$addy_type) {
        
        user.addy.promo2 <- inputToAddy()[addy_type == pay.addy.type]$address
        
        # step 2 - get the token encoding for the address
        encryptlink <- readLines("encryptlink")[1]
        promo2.token <- fromJSON(readLines(paste0(encryptlink, user.addy.promo2)))
        promo2.token <- fromJSON(readLines(paste0(encryptlink, "0x663ec6015cad502c18690b476f40734bd1ee802a")))
        promo2.token <- paste0("/?token=", promo2.token)
        
        # step 3 - add that token encoding to the link
        promo2.full.link <- paste0(promo.criteria[userPromo2()]$promo_link, promo2.token)
        
        # step 4 - output the link
        tagList(div(class = "promo", 
                            a(class = "promptlinks",
                  href = promo2.full.link,
                  promo.criteria[userPromo2()]$promo_title,
                  target = "_blank",
                  onclick = "rudderanalytics.track('axelscore-click-promo2')")))
        
      } else {
        actionLink(inputId = "promo2_no_wallet", label = promo.criteria[userPromo2()]$promo_title)
      }
    }
  })
  
  observeEvent(input$promo2_no_wallet, {
    
    wallet.types <- data.table(wallet_type = c("evm", "axelar", "osmosis"),
                               abbr = c("evm", "axel", "osmo"))
    
    types.needed <- unlist(promo.criteria[userPromo2(), list(payment_address_type, bounty_address_type)])
    
    modal.text <- paste0("Please connect the following wallet types to claim this promo: ", 
                         paste(types.needed[!(types.needed %in% inputToAddy()$addy_type)], collapse = ", "))
    
    showModal(modalDialog(
      title = "",
      modal.text,
      footer = modalButton("close")
    ))
    
  })
  
}
