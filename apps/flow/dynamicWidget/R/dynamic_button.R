#' Dynamic Button
#'
#' React Button for multi-wallet connect using Dynamic SDK
#'
#' @importFrom reactR createReactShinyInput
#' @importFrom htmltools htmlDependency tags
#'
#' @export
dynamic_buttonInput <- function(inputId) {
  reactR::createReactShinyInput(
    inputId,
    "dynamic_button",
    htmltools::htmlDependency(
      name = "dynamic_button-input",
      version = "1.0.0",
      src = "www/dynamicWidget/dynamic_button",
      package = "dynamicWidget",
      script = "dynamic_button.js"
    ),
    "",
    list(), htmltools::tags$div
  )
}

#' Dyanamic Button
#'
#' React Button for multi-wallet connect using Dynamic SDK
#'
#' @export
updateDynamic_buttonInput <- function(session, inputId, value, configuration = NULL) {
  message <- list(value = value)
  if (!is.null(configuration)) message$configuration <- configuration
  session$sendInputMessage(inputId, message)
}
