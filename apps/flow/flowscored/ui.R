
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
      column(7, textInput("addy", label = "Enter Your Address", value = "0x9244cd25314edd34"))
    ),
    
    fluidRow("Basic Stats"),
    
    fluidRow(
      column(6, ""),
      column(3, "YOU"),
      column(3, "Percentile")
    ),
    fluidRow(
      column(6, "# Trades"),
      column(3, textOutput("nft_n_trades")),
      column(3, textOutput("nft_n_trades_p"))
    ),
    fluidRow(
      column(6, "# days_since_last_tx"),
      column(3, textOutput("days_since_last_tx")),
      column(3, textOutput("days_since_last_tx_p"))
    ),
    fluidRow(
      column(6, "# Listings"),
      column(3, textOutput("nft_n_listings")),
      column(3, textOutput("nft_n_listings_p"))
    ),
    fluidRow(
      column(6, "# Projects Traded"),
      column(3, textOutput("nft_n_projects")),
      column(3, textOutput("nft_n_projects_p"))
    ),
    
    br(),hr(),br(),
    
    fluidRow("Awards!"),
    
    fluidRow(
      column(6, 
             textOutput("award_flowty_list"), "List an NFT on Flowty"),
      column(6, 
             textOutput("award_positive_trader"), "Positive Trader")
    ),
    
    fluidRow(
      column(6, 
             textOutput("award_own_flovatar"), "Own a Flovatar"),
      column(6, 
             textOutput("award_dex_swapper"), "Dex Swapper")
    ),
    
    br(),hr(),br(),
    
    fluidRow("On Chain Personas"),
    
    fluidRow(
      column(6, 
             "🏀 Topshot Trader"),
      column(6, 
             "📈 Defiaholic")
    ),
    
    br(),hr(),br(),
    
    fluidRow(
      column(8, "Overall you're a: ", div("Flow Hero", style = "color: #F2CD11")),
      column(4, "by Flipside")
    )
    

  
    
  ) # close wrapper
  
)