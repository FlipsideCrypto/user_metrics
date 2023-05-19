import { useDynamicContext } from "@dynamic-labs/sdk-react";
import { Button } from "reactstrap";
import { useEffect } from "react";

const DynamicAppUser = (props) => {
  const { user } = useDynamicContext();

  useEffect(async () => {
    if (user?.verifiedCredentials) {
      let wallets = [];
      wallets.push("dynamicId:" + user?.userId);
      if (window?.keplr) {
        await Promise.all(
          props.chains.map(async (chain) => {
            try {
              let address = await window.keplr.getKey(chain.chainId);
              wallets.push(chain.displayName + ":" + address?.bech32Address);
            } catch (err) {
              console.log("error", err);
            }
          })
        );
      }
      // also add evm chains
      user?.verifiedCredentials?.map((wallet) => {
        wallets.push(wallet.walletName + ":" + wallet.address);
      });
      props.setNewValue(wallets.toString());
    }
  }, [user]);

  return <></>;
};

export default DynamicAppUser;
