#' Wallet Handler
#'
#' Manages the wallet connection and network switching for EVM wallets.
#'
#' @importFrom reactR createReactShinyInput
#' @importFrom htmltools htmlDependency tags
#'
#' @export
WalletHandler <- function(inputId, chainId, default = "") {
  reactR::createReactShinyInput(
    inputId,
    "WalletHandler",
    htmltools::htmlDependency(
      name = "WalletHandler-input",
      version = "1.0.0",
      src = "www/opAttestR",
      package = "opAttestR",
      script = "main.js"
    ),
    default,
    configuration = list(
      chainId = chainId
    ),
    htmltools::tags$div
  )
}