
fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Roboto+Mono"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Inter")
  ),
  
  fluidRow(
    class = "wrapper",
    fluidRow(
      column(4, img(src = "flow_logo.png", width = "100px")),
      column(8, "Welcome 2 Flow-sanity")
      ),
    fluidRow(column(12, "Connect your wallets to see if you're a Flow Hero or a Flow Zero.")),
    
    fluidRow(
      column(2, ""),
      column(4, actionButton(inputId = "dapperconnect", img(src = "dapper.png", height = "75px"))),
      column(4, actionButton(inputId = "bloctoconnect", img(src = "blocto.png", height = "75px"))),
      column(2, "")
    ),
    
    fluidRow("180-Day Stats & Rankings"),
    
    fluidRow(
      column(6, ""),
      column(3, "YOU"),
      column(3, "Percentile")
    ),
    fluidRow(
      column(6, "# Trades"),
      column(3, textOutput(outputId = "nft_n_trades")),
      column(3, textOutput("nft_n_trades_p"))
    ),
    fluidRow(
      column(6, "# Days Since Last Txn"),
      column(3, textOutput("days_since_last_tx")),
      column(3, textOutput("days_since_last_tx_p"))
    ),
    fluidRow(
      column(6, "# NFT Listings"),
      column(3, textOutput("nft_n_listings")),
      column(3, textOutput("nft_n_listings_p"))
    ),
    fluidRow(
      column(6, "# Projects Traded"),
      column(3, textOutput("nft_n_projects")),
      column(3, textOutput("nft_n_projects_p"))
    ),
    
    br(),hr(),br(),
    
    fluidRow("Notable 180 Day Actions"),
    
    fluidRow(
      column(6, 
             div(class = 'actions', textOutput("action_listed_nft"), "Listed an NFT on Flowty")),
      column(6, 
             div(class = 'actions', textOutput("action_bought_nfts"), "Bought >3 NFTs"))
    ),
    
    fluidRow(
      column(6, 
             textOutput("action_staked_flow"), "Staked Flow"),
      column(6, 
             textOutput("action_dex_swap"), "Swapped on a Dex")
    ),
    
    br(),hr(),br(),
    
    fluidRow("Achievements"),
    
    fluidRow(
      column(6, 
             "🏀 Topshot Trader"),
      "Profitable NFT Trader",
      column(6, 
             "📈 Defiaholic")
    ),
    
    br(),hr(),br(),
    
    fluidRow(
      column(8, "Overall you're a: ", div("Flow Hero", style = "color: #F2CD11")),
      column(4, "by Flipside")
    )
    

  
    
  ) # close wrapper
  
) # close fluid page

