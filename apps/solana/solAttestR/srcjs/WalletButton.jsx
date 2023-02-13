import { SolWalletMultiButton } from "./SolWalletMultiButton.jsx";
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
import SolWalletWrapper from "./SolWalletWrapper.jsx";

const WalletButton = ({ setAddressForR }) => {

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
  <SolWalletWrapper>

          <SolWalletMultiButton setAddressForR={setAddressForR} />
    </SolWalletWrapper>

  )
};

export default WalletButton;