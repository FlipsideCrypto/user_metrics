import { ConnectionProvider, WalletProvider } from '@solana/wallet-adapter-react';
import { WalletModalProvider } from '@solana/wallet-adapter-react-ui';
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
import { clusterApiUrl } from '@solana/web3.js';
import React, { useMemo } from 'react';

require('@solana/wallet-adapter-react-ui/styles.css');
import { WalletAdapterNetwork } from '@solana/wallet-adapter-base';

const SolWalletWrapper = ({ children }) => {

  const solNetwork = WalletAdapterNetwork.Mainnet;
  const endpoint = useMemo(() => clusterApiUrl(solNetwork), [solNetwork]);

  const wallets = [
    new PhantomWalletAdapter(),
    new GlowWalletAdapter(),
    new SlopeWalletAdapter(),
    new SolflareWalletAdapter({ solNetwork }),
    new TorusWalletAdapter(),
    new LedgerWalletAdapter(),
    new SolletExtensionWalletAdapter(),
    new SolletWalletAdapter(),
];

return (

    <ConnectionProvider endpoint={endpoint}>
      <WalletProvider wallets={wallets}>
        <WalletModalProvider>
            { children }
        </WalletModalProvider>
      </WalletProvider>
    </ConnectionProvider>
  )
};

export default SolWalletWrapper;