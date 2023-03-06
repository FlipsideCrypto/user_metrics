#' Wallet_Connect
#'
#' Integrates with Dynamic Wallet Connect widget
#'
#' @importFrom reactR createReactShinyInput
#' @importFrom htmltools htmlDependency tags
#'
#' @export
wallet_connectInput <- function(inputId, default = "") {
  reactR::createReactShinyInput(
    inputId,
    "wallet_connect",
    htmltools::htmlDependency(
      name = "wallet_connect-input",
      version = "1.0.0",
      src = "www/flowAttestR/wallet_connect",
      package = "flowAttestR",
      script = "wallet_connect.js"
    ),
    default,
    list(),
    htmltools::tags$div
  )
}

#' <Add Title>
#'
#' <Add Description>
#'
#' @export
updateWallet_connectInput <- function(session, inputId, value, configuration = NULL) {
  message <- list(value = value)
  if (!is.null(configuration)) message$configuration <- configuration
  session$sendInputMessage(inputId, message)
}
