library(shiny)
library(dynamicWidget)

ui <- fluidPage(
  titlePanel("reactR Input Example"),
  dynamic_buttonInput("textInput", "2b9c5160-2795-44c3-ab0f-ed3bbe8d126c"),
  textOutput("textOutput")
)

server <- function(input, output, session) {
  output$textOutput <- renderText({
    sprintf("You entered: %s", input$textInput)
  })
}

shinyApp(ui, server)
