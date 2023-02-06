import { reactShinyInput } from 'reactR';
import WalletButton from "./WalletButton.jsx"
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';
import { useWallet } from '@solana/wallet-adapter-react';
import * as anchor from '@project-serum/anchor';
import { Connection, ConnectionConfig } from '@solana/web3.js';
import { clusterApiUrl } from '@solana/web3.js';
import { WalletAdapterNetwork } from '@solana/wallet-adapter-base';
import {
    GlowWalletAdapter,
    LedgerWalletAdapter,
    PhantomWalletAdapter,
    SlopeWalletAdapter,
    SolflareWalletAdapter,
    SolletExtensionWalletAdapter,
    SolletWalletAdapter,
    TorusWalletAdapter,
} from '@solana/wallet-adapter-wallets';
import { ConnectionProvider, WalletProvider } from '@solana/wallet-adapter-react';
import { WalletModalProvider } from '@solana/wallet-adapter-react-ui';
// import { getPhantomWallet } from '@solana/wallet-adapter-wallets';

require('@solana/wallet-adapter-react-ui/styles.css');


const SolWalletHandler = ({ configuration, setValue }) => {
    // const NETWORK = 'https://api.mainnet-beta.solana.com';
	// const walletContext = useWallet();
	// const config = {
	// 	commitment: 'confirmed',
	// 	disableRetryOnRateLimit: false,
	// 	confirmTransactionInitialTimeout: 150000
	// };
	// const connection = new Connection(NETWORK, config);
	// const provider = new anchor.Provider(connection, walletContext, config);
    // return (
    //     // <WalletButton setAddress={setValue} chainId={configuration.chainId}/>
    //     <div>
    //         <span>WalletHandler 2</span>
    //         {/* <WalletMultiButton /> */}
    //     </div>
    // )

	// you can use Mainnet, Devnet or Testnet here
    // const solNetwork = WalletAdapterNetwork.Mainnet;
    const endpoint = 'https://red-cool-wildflower.solana-mainnet.quiknode.pro/a1674d4ab875dd3f89b34863a86c0f1931f57090/';
    // initialise all the wallets you want to use
    // const wallets = [ getPhantomWallet() ];
    const wallets = [
        new PhantomWalletAdapter()
    ];

    // const wallets = useMemo(
    //     () => [
    //         new PhantomWalletAdapter(),
    //         new GlowWalletAdapter(),
    //         new SlopeWalletAdapter(),
    //         new SolflareWalletAdapter({ solNetwork }),
    //         new TorusWalletAdapter(),
    //         new LedgerWalletAdapter(),
    //         new SolletExtensionWalletAdapter(),
    //         new SolletWalletAdapter(),
    //     ],
    //     [solNetwork]
    // );

    // return (
    //     <ConnectionProvider endpoint={endpoint}>
    //          <WalletProvider wallets={wallets}>
    //              <WalletModalProvider>
    //                 <div className="test2">
    //                     Test22
    //                     <div>
    //                         <WalletMultiButton />
    //                     </div>
    //                 </div>
    //             </WalletModalProvider>
    //         </WalletProvider>
    //     </ConnectionProvider>
    // );
    return (
        <ConnectionProvider endpoint={endpoint}>
            <WalletProvider wallets={wallets}>
                <WalletModalProvider>
                    <div onClick={() => {console.log('Div clicked');}} className="soltest2">
                        SOL Test 1234
                    </div>
                    <div>
                        <WalletMultiButton onClick={() => {console.log('Button clicked');}} />
                    </div>
                </WalletModalProvider>
            </WalletProvider>
        </ConnectionProvider>
    );
}

export default function initSolWalletHandler() {
    reactShinyInput(
      '.SolWalletHandler', 
      'solAttestR.SolWalletHandler', 
      SolWalletHandler
    );
}