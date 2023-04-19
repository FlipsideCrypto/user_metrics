library(shiny)
library(cosmosDynamicWidget)

ui <- fluidPage(
  titlePanel("reactR Input Example"),
  dynamic_buttonInput("textInput", maxHeight = "3.5"),
  textOutput("textOutput")
)

server <- function(input, output, session) {
  output$textOutput <- renderText({
    sprintf("You entered: %s", input$textInput)
  })
}

shinyApp(ui, server)
