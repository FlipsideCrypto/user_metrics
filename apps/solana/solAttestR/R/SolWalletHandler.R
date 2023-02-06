#' SolWallet Handler
#'
#' Manages the wallet connection and network switching for EVM wallets.
#'
#' @importFrom reactR createReactShinyInput
#' @importFrom htmltools htmlDependency tags
#'
#' @export
SolWalletHandler <- function(inputId, default = "") {
  reactR::createReactShinyInput(
    inputId,
    "SolWalletHandler",
    htmltools::htmlDependency(
      name = "SolWalletHandler-input",
      version = "1.0.0",
      src = "www/solAttestR",
      package = "solAttestR",
      script = "main.js"
    ),
    default,
    configuration = list(
    ),
    htmltools::tags$div
  )
}