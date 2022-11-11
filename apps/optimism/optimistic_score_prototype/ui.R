fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Roboto+Mono"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Inter")
  ),
  
  fluidRow(class = "wrapper",
           fluidRow(img(src = "app_logo.svg")),
           
           fluidRow(class = "walletpart",
                    actionButton("connect", icon = icon("wallet"), label = "Connect Wallet"),
                    bsModal(id = "connectpop", title = "", trigger = "connect",
                            metamaskConnect("ethaddress")),
                    textOutput("connectedaddress")
           ),
           
           fluidRow("Earn 1 star for doing each thing on Optimism in the last 180 days:"),
           
           fluidRow(class = "scorebox", imageOutput("airdropscore"), "Claimed the original OP airdrop"),
           fluidRow(class = "scorebox", imageOutput("nftscore"), "Bought or Sold at least 1 NFT"),
           fluidRow(class = "scorebox", imageOutput("delegatescore"), "Delegated OP at least once"),
           fluidRow(class = "scorebox", imageOutput("cexscore"), "Sent $0 to an exchange or bought more than you sold"),
           fluidRow(class = "scorebox", imageOutput("dexscore"), "Swapped at least once on a dex"),
           hr(),
           fluidRow(class = "totalscore", textOutput("totalscore")),
           fluidRow(class = "proveit", actionButton(inputId = "attest", label = "PROVE IT on chain!"))
           
  ),
  
)