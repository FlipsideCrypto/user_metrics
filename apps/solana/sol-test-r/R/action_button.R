action_buttonInput <- function(inputId, default = "") {
  reactR::createReactShinyInput(
    inputId,
    "action_button",
    htmltools::htmlDependency(
      name = "action_button-input",
      version = "1.0.0",
      src = "www/reactstrapTest/action_button",
      package = "reactstrapTest",
      script = "action_button.js"
    ),
    default,
    list(),
    htmltools::tags$span
  )
}