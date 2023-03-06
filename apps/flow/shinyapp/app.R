library(shiny)
library(dynamicWidget)


ui <- fluidPage(
    titlePanel("dynamic test"),
    dynamic_buttonInput("my_wallet")
)

# Define server logic to plot various variables against mpg ----
server <- function(input, output) {
    observeEvent(input$my_wallet, {
        print(input$my_wallet)
    })
}
shinyApp(ui, server)
