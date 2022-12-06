#' Sign Message Backend
#'
#' Given the configuration arguments, this function will sign a message by the
#' given private key and return the signed message.
#'
#' @importFrom reactR createReactShinyInput
#' @importFrom htmltools htmlDependency tags
#'
#' @export
SignMessageBackend <- function(
    inputId, 
    chainId,
    privateKey, 
    provider, 
    messageArguments, 
    default = ""
) {
  reactR::createReactShinyInput(
    inputId,
    "SignMessageBackend",
    htmltools::htmlDependency(
      name = "SignMessageBackend-input",
      version = "1.0.0",
      src = "www/opAttestR",
      package = "opAttestR",
      script = "main.js"
    ),
    default,
    configuration = list(
        chainId = chainId,
        privateKey = privateKey,
        provider = provider,
        messageArguments = messageArguments
    ),
    htmltools::tags$div
  )
}