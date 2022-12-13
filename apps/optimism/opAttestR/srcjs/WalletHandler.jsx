import WalletButton from "./WalletButton.jsx"
import WalletWrapper from "./WalletWrapper.jsx"
import { reactShinyInput } from 'reactR';

const WalletHandler = ({ configuration, setValue }) => {
    return (
        <WalletWrapper>
            <WalletButton setAddress={setValue} chainId={configuration.chainId}/>
        </WalletWrapper>
    )
}

export default function initWalletHandler() {
    reactShinyInput(
      '.WalletHandler', 
      'opAttestR.WalletHandler', 
      WalletHandler
    );
}