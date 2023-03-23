fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Roboto+Mono"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Open+Sans"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Rubik"),
    tags$script(src = "rudderstack.js")
  ),
  
  fluidRow(class = "titlebar",
           column(9, img(src = "app_logo.svg", height = "44px", style = "margin-left: 13px; margin-top: 13px; margin-bottom: 13px;")),
           column(3, style = "text-align: right;", actionButton("connect", icon = icon("wallet"), label = "  Connect Wallet")),
           bsModal(id = "connectpop", title = "", trigger = "connect",
                   WalletHandler("eth_address", chainId = 10),
                   br(),
                   a("How to connect MetaMask to Optimism", 
                     href = "https://help.optimism.io/hc/en-us/articles/6223777057179-How-do-I-use-Optimism-with-MetaMask-",
                     target = "_blank", style = "font-style: italic;"))
  ),
  fluidRow(class = "wrapper",
           
           fluidRow(class = "scoreholder",
                    fluidRow(class = "description", div("Score up to 5 points by doing things that contribute to the Optimism Network. Then click 'Attest Your Score On Chain' to use the ",
                                                        a("AttestationStation", 
                                                          href = "https://community.optimism.io/docs/governance/attestation-station/", 
                                                          onclick = "rudderstack.track('optimist-click-attestation-station')",
                                                          target = "_blank"),
                                                        " to get your score onchain.")),
                    br(),
                    fluidRow(class = "scorebox", 
                             div(class = "alignholder", 
                                 div(class = "left", textOutput("airdropscore")),
                             div(class = "text", "Claimed the original OP airdrop") )
                    ),
                    fluidRow(class = "scorebox", 
                             div(class = "alignholder", 
                                 div(class = "left", textOutput("delegatescore")),
                                 div(class = "text", "Delegated OP at least once") )
                    ),
                    fluidRow(class = "scorebox", 
                             div(class = "alignholder", 
                                 div(class = "left", textOutput("dexscore")),
                                 div(class = "text", "Swapped at least once on a dex") )
                    ),
                    fluidRow(class = "scorebox", 
                             div(class = "alignholder", 
                                 div(class = "left", textOutput("nftscore")),
                                 div(class = "text", "Bought or Sold at least 1 NFT") )
                    ),
                    fluidRow(class = "scorebox", 
                             div(class = "alignholder", 
                                 div(class = "left", textOutput("cexscore")),
                                 div(class = "text", "Sent $0 to a cex or bought more than sold") )
                    ),
                    
                    
                    br(),
                    fluidRow(div(class = "totalscorebox", 
                                    div(class = "scorecircle", textOutput("totalscore")),
                             div(class = "scorecolumns", uiOutput("tx_handler"))
                             )
                    )
           ),
           br(),
           
           fluidRow(class = "bottom", 
                    div(class = "LINKS", "FAQ:"),
                    div(class = "links", 
                        a(href = "https://community.optimism.io/docs/governance/attestation-station/", 
                          "What is Attestation Station?", 
                          onclick = "rudderstack.track('optimist-click-attestation-station')",
                          target = "_blank")),
                    div(class = "links", 
                        a(href = "https://github.com/FlipsideCrypto/user_metrics/tree/main/apps/optimism/optimistic_score_prototype", 
                          "Can I have this code?", 
                          onclick = "rudderstack.track('optimist-click-github')",
                          target = "_blank")),
                    div(class = "links", 
                        a(href = "https://app.flipsidecrypto.com/dashboard/optimist-score-queries-data-Jp7kIN", 
                          "Can I have this data?", 
                          onclick = "rudderstack.track('optimist-click-velocity')",
                          target = "_blank")),
                    div(class = "links", 
                        a(href = "https://flipsidecrypto.xyz/", "What is Flipside?", 
                          onclick = "rudderstack.track('optimist-click-flipsidexyz')",
                          target = "_blank"))
                    )
                    
                    
  ),
  
)