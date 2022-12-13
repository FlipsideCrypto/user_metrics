import WalletWrapper from "./WalletWrapper.jsx";
import TransactionButton from "./TransactionButton.jsx";
import { reactShinyInput } from "reactR";

const TransactionHandler = ({ configuration, value, setValue }) => {
    return (
        <WalletWrapper>
            <TransactionButton configuration={configuration} value={value} setValue={setValue} />
        </WalletWrapper>
    )
}

export default function initTransactionHandler() {
    reactShinyInput(
      '.TransactionHandler', 
      'opAttestR.TransactionHandler', 
      TransactionHandler
    );
 }