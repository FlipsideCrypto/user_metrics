#' Transaction Handler
#'
#' Given the configuration arguments, this function will prepare an EVM transaction
#' and display a button that will run the transaction when clicked.
#'
#' @importFrom reactR createReactShinyInput
#' @importFrom htmltools htmlDependency tags
#'
#' @export
TransactionHandler <- function(
    inputId, 
    label, 
    chainId,
    contract_address, 
    contract_abi, 
    contract_method,
    provider,
    signerPrivateKey,
    args, 
    enabled,
    default = ""
) {
  reactR::createReactShinyInput(
    inputId,
    "TransactionHandler",
    htmltools::htmlDependency(
      name = "TransactionHandler-input",
      version = "1.0.0",
      src = "www/opAttestR",
      package = "opAttestR",
      script = "main.js"
    ),
    default,
    configuration = list(
        label = label,
        chainId = chainId,
        contract_address = contract_address,
        contract_abi = contract_abi,
        contract_method = contract_method,
        provider = provider,
        signerPrivateKey = signerPrivateKey,
        args = args,
        enabled = enabled
    ),
    htmltools::tags$div
  )
}