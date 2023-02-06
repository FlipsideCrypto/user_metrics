import { useEffect } from "react";
import { useConnect, useAccount, useDisconnect, useSwitchNetwork, useNetwork } from "wagmi";

const WalletButton = ({ setAddress, chainId }) => {
  const { address } = useAccount();
  const { connect, connectors, isLoading, pendingConnector } = useConnect();
  const { disconnect } = useDisconnect();
  const { chain } = useNetwork();
  const { switchNetwork } = useSwitchNetwork({
    chainId: chainId ?? 10
  });

  useEffect(() => {
    setAddress(address ?? "");
  }, [address])

  return (
    <div>
      {/* {address ? 
        <>
          {chain?.id === chainId ?
            <button onClick={() => disconnect()}>
              Disconnect1
            </button>
            :
            <button onClick={() => switchNetwork()}>
              Switch Network1
            </button>
          }
        </>
        :
        <>
          {connectors.map((connector) => (
            <button
              disabled={!connector.ready}
              key={connector.id}
              onClick={() => connect({ connector })}
            >1
              {connector.name}
              {isLoading &&
                pendingConnector?.id === connector.id &&
                ' (connecting)'}
            </button>
          ))}
        </>
      } */}
      Wallet Button
    </div>
  )
};

export default WalletButton;