import { configureChains, createClient, WagmiConfig, chain, defaultChains} from 'wagmi';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public';
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect'
import { MetaMaskConnector } from 'wagmi/connectors/metaMask'

const WalletWrapper = ({ children }) => {
    const { chains, provider } = configureChains(
        [...defaultChains, chain.optimism, chain.polygon, chain.arbitrum, chain.optimismGoerli],
        [
          alchemyProvider({ apiKey: "yw-o6jg0XG7Qn3H_8dxPEgYJe-zG6r0_" }),
          publicProvider()
        ]
      );
            
      const connectors = () => {
        return [
          new MetaMaskConnector({ 
            chains: chains,
            options: {
              shimDisconnect: true,
              UNSTABLE_shimOnConnectSelectAccount: true
            }
          }),
          new WalletConnectConnector({
            options: {
              qrcode: true,
            },
          }),
        ];
      }
      
      const wagmiClient = createClient({
        autoConnect: true,
        connectors,
        provider
      })

    return (
        <WagmiConfig client={wagmiClient}>
          { children }
        </WagmiConfig>
    )
}

export default WalletWrapper;