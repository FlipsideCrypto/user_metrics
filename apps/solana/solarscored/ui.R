# #useraddy .form-group {
# display: table-row;
# }
# 
# #addy-label {
# padding-right: 30px;
# }

fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "wallet.css"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Orbitron"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Exo+2"),
    tags$script(src = "rudderstack.js"),
    tags$link(rel = "icon", href = "flipside.svg")
  ),
  
  useShinyjs(),
  chooseSliderSkin("Round"),
  
  fluidRow(class = "titlerow", 
           column(8, class = "title", img(src = "solarscored-logo.svg", width = '480px')),
           column(4,
                  div(id = "icons",
                      div(class = "aboutlinks", 
                          a(id = 'fork', 
                            href = "https://github.com/FlipsideCrypto/user_metrics/tree/main/apps/solana/solarscored",
                            img(src = "github.svg", width = "35px"),
                            onclick = "rudderstack.track('solarscored-click-github')",
                            target = "_blank")),
                      bsTooltip(id = "fork", 
                                title = "Fork this App",
                                placement = "bottom", trigger = "hover"),
                      div(class = "aboutlinks flippylink", 
                          a(id = "flippy",
                            href = "https://flipsidecrypto.xyz/",
                            img(src = "flipside.svg", width = "35px"),
                            onclick = "rudderstack.track('solarscored-click-flipside')",
                            target = "_blank")),
                      bsTooltip(id = "flippy", 
                                title = "Get the Data",
                                placement = "bottom", trigger = "hover"),
                      div(class = "aboutlinks", 
                          a(id = "solana", href = "https://solana.com",
                            img(src = "solana.svg", width = "35px"),
                            onclick = "rudderstack.track('solarscored-click-solana')",
                            target = "_blank")),
                      bsTooltip(id = "solana", 
                                title = "Solana",
                                placement = "bottom", trigger = "hover"),
                      SolWalletHandler("sol_address")
                      
                  ))),
  
  fluidRow(class = "appbody",
           
           fluidRow(class = "dashmid",
                    column(7, 
                           div(class = "addybuttons", 
                           uiOutput("useraddy"),
                           actionButton(inputId = "randomaddy", label = img(src = "random.svg", height = "26"))),
                           bsTooltip(id = "randomaddy", 
                                     title = "show a random address",
                                     placement = "bottom", trigger = "hover"),
                           
                           div(id = "wheelpart", 
                               uiOutput("svgout") %>% 
                                 withSpinner(hide.ui = FALSE, color = "#9945FF", size = 2)),
                           a(id = "pic", 
                             capture::capture(
                               selector = "#wheelpart",
                               filename = "mysolarscore.png",
                               options = list(backgroundColor = "#FFF"),
                               #scale = 2,
                               img(src = "camera.svg", height = "20"),
                               onclick = "rudderstack.track('solarscored-camera')",
                               title = "Download the Circle")),
                           bsTooltip(id = "pic", 
                                     title = "Download the Wheel",
                                     placement = "top", trigger = "hover"),
                           
                           
                    ),
                    
                    column(5, 
                           div(id = "leftbox", 
                               div(class = "boxtitle", "Address Metrics"),
                               
                               div(id = "totalscore",
                                   div(class = "score", textOutput("userscore")),
                                   div(class = "yourscore", "SolarScore")),
                               bsTooltip(id = "totalscore", 
                                         title = paste0("Your total score out of a possible 21 points, up to 3 for each of the 7 categories. ",
                                                        last.blocks),
                                         placement = "top", trigger = "hover"),
                               
                               fluidRow(class = "metricrow",
                                        div(class = "metricholder", id = "boxuseractivity",
                                            div(class = "metric", textOutput("useractivity")),
                                            div(class = "metricname", "Activity"),
                                            bsTooltip(id = "boxuseractivity", 
                                                      title = "# transactions in the last 90 days.",
                                                      placement = "top", trigger = "hover")),
                                        
                                        div(class = "metricholder", id = "boxusernfts", 
                                            div(class = "metric", textOutput("usernfts")),
                                            div(class = "metricname", "NFTs"),
                                            bsTooltip(id = "boxusernfts", 
                                                      title = "90 day buy + mint volume (SOL)",
                                                      placement = "top", trigger = "hover")),
                                        
                                        div(class = "metricholder", id = "boxusergovernance",
                                            div(class = "metric", textOutput("usergovernance")),
                                            div(class = "metricname", "Gov"),
                                            bsTooltip(id = "boxusergovernance", 
                                                      title = "# governance votes in the last 90 days",
                                                      placement = "top", trigger = "hover")),
                                        
                                        div(class = "metricholder", id = "boxuservariety", 
                                            div(class = "metric", textOutput("uservariety")),
                                            div(class = "metricname", "Variety"),
                                            bsTooltip(id = "boxuservariety", 
                                                      title = "# programs interacted with in the last 90 days",
                                                      placement = "top", trigger = "hover"))
                               ),
                               
                               fluidRow(class = "metricrow",
                                        div(class = "metricholder2", id = "boxuserstaking", 
                                            div(class = "metric", textOutput("userstaking")),
                                            div(class = "metricname", "Staking"),
                                            bsTooltip(id = "boxuserstaking", 
                                                      title = "SOL currently staked",
                                                      placement = "top", trigger = "hover")),
                                        
                                        div(class = "metricholder2", id = "boxuserlongevity", 
                                            div(class = "metric", textOutput("userlongevity")),
                                            div(class = "metricname", "Longevity"),
                                            bsTooltip(id = "boxuserlongevity", 
                                                      title = "# calendar months with a transaction in the last 90 days",
                                                      placement = "top", trigger = "hover")),
                                        
                                        div(class = "metricholder2", id = "boxuserbridge",
                                            div(class = "metric", textOutput("userbridge")),
                                            div(class = "metricname", "Bridging"),
                                            bsTooltip(id = "boxuserbridge", 
                                                      title = "# times funds bridged onto Solana in the last 90 days",
                                                      placement = "top", trigger = "hover"))
                               ),
                               div(id = "hovernote", "Hover over Metric for Details"),
                           ),
                           br(),
                           div(id = "botrightbox", 
                               div(class = "boxtitle", "Download All Scores"),
                               div(id = "indent", "Select Addresses by Score:"),
                               div(id = "sliderbox",
                                   plotlyOutput("scorehist", height = "100px"),
                                   uiOutput("outputslider"),
                                   a(uiOutput("bdnldscores"), onclick = "rudderstack.track('solarscored-click-solana')")
                                   ))
                           
                    ) #close left column box
                    
                    
                    
                    
                    
           ) # close dashmid
           
           #fluidRow(class = "dashbottom", "this is the bottom!")
           
  ), #close appbody
  br(), br(), br()
  
  
) # close app
