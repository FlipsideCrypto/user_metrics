
fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css"),
    #tags$script(src = "rudderstack.js"),
    tags$link(rel = "icon", href = "flipside.svg")
  ),
  
  fluidRow(class = "flex-container",
           column(1, div(class = "top-border"), id = "leftcol", 
                  div(class = "diagonal-lines"),
                  br(),
                  "Axelar Trends",
                  br(),br(),
                  paste0("#1 Destination: ", axelar.stats$no1_destination),
                  br(),br(),
                  paste0("#1 Source: ", axelar.stats$no1_source),
                  br(),br(),
                  paste0("Avg Xfer ", axelar.stats$avg_xfer_usd),
                  hr(),
                  "News U Can Use",
                  br(),br(),
                  a(href = "https://flipsidecrypto.xyz/hess/optimism-axelar-bridge-analysis-1gFzQ_",
                    "Optimism + Axelar Bridge Analysis",
                    onclick = "rudderstack.track('flowscored-click-github')",
                    target = "_blank"),
                  br(),
                  a(href = "https://flipsidecrypto.xyz/panda-gXSkiX/axelar-arb-everywhere-jADwcy",
                    "Axelar: ARB Everywhere",
                    onclick = "rudderstack.track('flowscored-click-github')",
                    target = "_blank"),
                  br(),
                  a(href = "https://flipsidecrypto.xyz/m-zamani-WmWD3E/squid-launch-analysis-I0O-nv",
                    "Squid Launch Analysis",
                    onclick = "rudderstack.track('flowscored-click-github')",
                    target = "_blank"),
                  div(class = "last-child-border")),
           column(10,
                  fluidRow(class = "titlerow", 
                           column(2, div(class = "upperwords", "No. 1 Choice for Bridgemen and Boatsmen")),
                           column(1, div(class = "upperwords", "ALL ARE SCORED")),
                           column(6, class = "title", img(src = "logo.svg", height = '75px')),
                           column(1, div(class = "upperwords", "COURTESY OF FLIPSIDE")),
                           column(2, class = "upperwords",
                                  #div(id = "icons",
                                  div(
                                    div(a(id = 'fork', 
                                          href = "https://github.com/FlipsideCrypto/user_metrics/tree/main/apps/flow/flowscored",
                                          #img(src = "github.svg", width = "30px"),
                                          "get code",
                                          onclick = "rudderstack.track('flowscored-click-github')",
                                          target = "_blank")),
                                    bsTooltip(id = "fork", 
                                              title = "Fork this App",
                                              placement = "bottom", trigger = "hover"),
                                    icon('anchor'),
                                    div(a(id = "flippy",
                                          href = "https://flipsidecrypto.xyz/edit/queries/5278823a-aa1e-4677-910d-51a49cb7cda0",
                                          #img(src = "flipside.svg", width = "30px"),
                                          "fork queries",
                                          onclick = "rudderstack.track('flowscored-click-flipside')",
                                          target = "_blank")),
                                    bsTooltip(id = "flippy", 
                                              title = "Get the Data",
                                              placement = "bottom", trigger = "hover")
                                  )
                           )
                  ),  
                  fluidRow(id = "mainsection",
                           column(8, class = "mapcol",
                                  div(id = "holdd3", d3Output("d3", height = "700px", width = "700px"),
                                      textOutput("clickedstation"))),
                           
                           column(4,
                                  div(class = "connect", dynamic_buttonInput("my_wallet")),
                                  
                                  hr(),
                                  div(class = "promo", "learn to use Axelar >>"),
                                  
                                  hr(),
                                  
                                  br(),
                                  div(class = "title", "YOUR SCORE + USER PERSONA"),
                                  
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("usertotalscore")),
                                          div(class = "scoretitle", "Total Score")
                                      )
                                  ),
                                  
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("squidscore")),
                                          div(class = "scoretitle", "Squid Score")
                                      ),
                                      div(class = "rightbox",
                                          div(class = "score", textOutput("squidbonus")),
                                          div(class = "scoretitle", "Squid Bonus")
                                      )
                                  ),
                                  
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("satellitescore")),
                                          div(class = "scoretitle", "Satellite Score")
                                      ),
                                      div(class = "rightbox",
                                          div(class = "score", textOutput("satellitebonus")),
                                          div(class = "scoretitle", "Satellite Bonus")
                                      )
                                  ),
                                  
                                  
                                  
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("usagescore")),
                                          div(class = "scoretitle", "Usage Score")
                                      ),
                                      div(class = "rightbox",
                                          div(class = "score", textOutput("passportscore")),
                                          div(class = "scoretitle", "Passport Bonus")
                                      )
                                  ),
                                  div(class = "scorecontainer", 
                                      div(class = "leftbox",
                                          div(class = "score", uiOutput("personaicon1"), uiOutput("personaicon2")),
                                          div(class = "scoretitle",  textOutput("persona"))
                                      )),
                                  hr(),
                                  div(class = "promo", "click to see your special deal! >>")
                           ) # close right column 4
                  ) #close middle fluid row
           ), # close middle column
           column(1, id ="rightcol", 
                  div(class = "diagonal-lines"),
                  br(),
                  uiOutput("randomaddylink"),
                  hr(),
                  uiOutput("everythinglink"),
                  hr(),
                  textOutput("mostvisitedchain"),
                  hr(),
                  "Where Next?",
                  br(),br(),
                  a(href = "https://flipsidecrypto.xyz",
                    div(img(src = "flipside.svg", width = "28px"), HTML("<br>FLIPSIDE")),
                    onclick = "rudderstack.track('flowscored-click-flipside')",
                    target = "_blank"),
                  br(),
                  a(href = "https://axelar.network",
                    div(img(src = "axelar.svg", width = "30px"), HTML("<br>AXELAR")),
                    onclick = "rudderstack.track('flowscored-click-axelar')",
                    target = "_blank"),
                  br(),
                  a(href = "https://www.squidrouter.com",
                    div(img(src = "squid_logo.svg", width = "30px"), HTML("<br>SQUID")),
                    onclick = "rudderstack.track('flowscored-click-squid')",
                    target = "_blank"),
                  br(),
                  a(href = "https://satellite.money",
                    div(img(src = "satellite_logo.svg", width = "30px"), HTML("<br>SATELLITE")),
                    onclick = "rudderstack.track('flowscored-click-satellite')",
                    target = "_blank"),
                  br(),
                  div(class = "last-child-border"))
  )
)

