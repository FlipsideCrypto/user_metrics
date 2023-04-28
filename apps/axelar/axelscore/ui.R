
fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "dynamicbutton.css"),
    tags$script(src = "rudderstack.js"),
    tags$link(rel = "icon", href = "flipside.svg")
  ),
  
  fluidRow(class = "flex-container",
           column(1, div(class = "top-border"), id = "leftcol", 
                  div(class = "diagonal-lines"),
                  br(),
                  "Axelar Trends",
                  br(),br(),
                  paste0("#1 Source Chain ", axelar.stats$no1_source),
                  br(),br(),
                  paste0("#1 Dest. Chain ", axelar.stats$no1_destination),
                  br(),br(),
                  paste0("Avg Xfer ", axelar.stats$avg_xfer_usd),
                  hr(),
                  p("News U Can Use", style = "font-weight: 700;"),
                  br(),
                  a(href = trending.links$link_url[1],
                    trending.links$link_text[1],
                    onclick = "rudderanalytics.track('axelscore-click-news')",
                    target = "_blank"),
                  br(),
                  a(href = trending.links$link_url[2],
                    trending.links$link_text[2],
                    onclick = "rudderanalytics.track('axelscore-click-news')",
                    target = "_blank"),
                  br(),
                  a(href = trending.links$link_url[3],
                    trending.links$link_text[3],
                    onclick = "rudderanalytics.track('axelscore-click-news')",
                    target = "_blank"),
                  div(class = "last-child-border")),
           column(10,
                  fluidRow(class = "toptitlerow", 
                           column(2, div(class = "upperwords", "No. 1 Choice for Bridgeoors and Boatoors")),
                           column(1, div(class = "upperwords", "ALL ARE SCORED")),
                           column(6, class = "titlelogo", img(id = "axlogo", src = "logo.svg", height = '75px')),
                           column(1, div(class = "upperwords", "COURTESY OF FLIPSIDE")),
                           column(2, class = "upperwords",
                                  #div(id = "icons",
                                  div(
                                    div(a(id = 'fork', 
                                          href = "https://github.com/FlipsideCrypto/user_metrics/tree/main/apps/axelar/axelscore",
                                          #img(src = "github.svg", width = "30px"),
                                          "get code",
                                          onclick = "rudderanalytics.track('axelscore-click-github')",
                                          target = "_blank")),
                                    bsTooltip(id = "fork", 
                                              title = "fork this app on github",
                                              placement = "bottom", trigger = "hover"),
                                    icon('anchor'),
                                    div(a(id = "flippy",
                                          href = "https://flipsidecrypto.xyz/edit/queries/5278823a-aa1e-4677-910d-51a49cb7cda0",
                                          #img(src = "flipside.svg", width = "30px"),
                                          "fork queries",
                                          onclick = "rudderanalytics.track('axelscore-click-flipside')",
                                          target = "_blank")),
                                    bsTooltip(id = "flippy", 
                                              title = "fork these queries on Flipside",
                                              placement = "bottom", trigger = "hover")
                                  )
                           )
                  ),  
                  fluidRow(id = "mainsection", br(),
                           column(8, class = "mapcol",
                                  div(id = "holdd3", d3Output("d3", height = "700px", width = "700px"),
                                      textOutput("clickedstation"))),
                           
                           column(4,
                                  div(class = "connect", 
                                      #"CONNECT WALLET HERE"
                                      dynamic_buttonInput("my_wallet")),
                                  
                                  hr(),
                                  
                                  div(class = "title", "YOUR SCORE + USER PERSONA"),
                                  div(class = "note", "hover for descriptions"),
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("usertotalscore")),
                                          div(class = "scoretitle", "Total Score")
                                      )
                                  ),
                                  
                                  bsTooltip(id = "usertotalscore", 
                                            title = "each score + bonus added together",
                                            placement = "bottom", trigger = "hover"),
                                  
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("squidscore")),
                                          div(class = "scoretitle", "Squid Score")
                                      ),
                                      bsTooltip(id = "squidscore", 
                                                title = "up to 3 points based your # of squid transfers and transfer $",
                                                placement = "bottom", trigger = "hover"),
                                      
                                      div(class = "rightbox",
                                          div(class = "score", textOutput("squidbonus")),
                                          div(class = "scoretitle", "Squid Bonus")
                                      ),
                                      bsTooltip(id = "squidbonus", 
                                                title = "an additional point for having a very high number of squid transfers or a very high transfer volume",
                                                placement = "bottom", trigger = "hover")
                                  ),
                                  
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("satellitescore")),
                                          div(class = "scoretitle", "Satellite Score")
                                      ),
                                      bsTooltip(id = "satellitescore", 
                                                title = "up to 3 points based your # of satellite transfers and transfer $",
                                                placement = "bottom", trigger = "hover"),
                                      
                                      div(class = "rightbox",
                                          div(class = "score", textOutput("satellitebonus")),
                                          div(class = "scoretitle", "Satellite Bonus")
                                      ),
                                      bsTooltip(id = "satellitebonus", 
                                                title = "an additional point for having a very high number of satellite transfers or a very high transfer volume",
                                                placement = "bottom", trigger = "hover")
                                  ),
                                  
                                  
                                  
                                  div(class = "scorecontainer",
                                      div(class = "leftbox",
                                          div(class = "score", textOutput("usagescore")),
                                          div(class = "scoretitle", "Usage Score")
                                      ),
                                      bsTooltip(id = "usagescore", 
                                                title = "1 point for each protocol used (squid + satellite)",
                                                placement = "bottom", trigger = "hover"),
                                      
                                      div(class = "rightbox",
                                          div(class = "score", textOutput("passportscore")),
                                          div(class = "scoretitle", "Passport Score")
                                      ),
                                      bsTooltip(id = "passportscore", 
                                                title = "1 point per chain visited",
                                                placement = "bottom", trigger = "hover"),
                                  ),
                                  div(class = "scorecontainer", 
                                      div(class = "leftbox",
                                          div(class = "score", uiOutput("personaicon1"), uiOutput("personaicon2")),
                                          div(class = "scoretitle",  textOutput("persona"))
                                      )),
                                  hr(),
                                  div(class = "title", uiOutput("promotitle")),
                                  column(6, class = "promocolumn", div(class = "promo", uiOutput("promo1"))),
                                  column(6, class = "promocolumn", div(class = "promo", uiOutput("promo2")))
                                  
                                  
                           ) # close right column 4
                  ) #close middle fluid row
           ), # close middle column
           column(1, id ="rightcol", 
                  div(class = "diagonal-lines"),
                  br(),
                  div(class = "faq", 
                      a(href = "https://science.flipsidecrypto.xyz/axelscore-faq", 
                        "> FAQ <",
                        onclick = "rudderanalytics.track('axelscore-click-faq')",
                        target = "_blank")),
                  hr(),
                  uiOutput("randomaddylink"),
                  hr(),
                  uiOutput("everythinglink"),
                  hr(),
                  textOutput("mostvisitedchain"),
                  hr(),
                  "Where Next?",
                  br(),br(),
                  a(href = "https://flipsidecrypto.xyz",
                    div(class = "imginline", img(class = "imginline", src = "flipside.svg", width = "28px"), HTML("<br>FLIPSIDE")),
                    onclick = "rudderanalytics.track('axelscore-click-flipside')",
                    target = "_blank"),
                  br(),
                  a(href = "https://axelar.network",
                    div(class = "imginline", img(class = "imginline", src = "axelar.svg", width = "30px"), HTML("<br>AXELAR")),
                    onclick = "rudderanalytics.track('axelscore-click-axelar')",
                    target = "_blank"),
                  br(),
                  a(href = "https://www.squidrouter.com",
                    div(class = "imginline", img(class = "imginline", src = "squid_logo.svg", width = "30px"), HTML("<br>SQUID")),
                    onclick = "rudderanalytics.track('axelscore-click-squid')",
                    target = "_blank"),
                  br(),
                  a(href = "https://satellite.money",
                    div(class = "imginline", img(class = "imginline", src = "satellite_logo.svg", width = "30px"), HTML("<br>SATELLITE")),
                    onclick = "rudderanalytics.track('axelscore-click-satellite')",
                    target = "_blank"),
                  br(),
                  div(class = "last-child-border"))
  )
)

