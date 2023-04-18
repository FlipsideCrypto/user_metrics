import { useDynamicContext } from "@dynamic-labs/sdk-react";
import { Button } from "reactstrap";
import { useEffect } from "react";

const DynamicAppUser = (props) => {
  const { user } = useDynamicContext();

  // const provider = useCosmosProvider();

  useEffect(async () => {
    console.log("app user ");
    // console.log("user", JSON.stringify(user, null, 2));
    // console.log("user?.verifiedCredentials", user?.verifiedCredentials);
    if (user?.verifiedCredentials) {
      // console.log(
      //   "ok then ",
      //   user.verifiedCredentials.map(
      //     (wallet) => wallet.walletName + ":" + wallet.address
      //   )
      // );

      let wallets = [];
      if (window?.keplr) {
        await Promise.all(
          props.chains.map(async (chain) => {
            try {
              let address = await window.keplr.getKey(chain.chainId);
              wallets.push(chain.displayName + ":" + address?.bech32Address);
              console.log(wallets);
            } catch (err) {
              console.log("error", err);
            }
          })
        );
        // also add evm chains
        .user?.verifiedCredentials?.map((wallet) => {
          wallets.push(wallet.walletName + ":" + wallet.address);
        });
        props.setNewValue(wallets.toString());
      }

      // let axelarAddress = await window?.keplr?.getKey("axelar-dojo-1");
      // // console.log("axelar address", axelarAddress?.bech32Address);
      // let osmosisAddress = await window?.keplr?.getKey("osmosis-1");
      // props.setNewValue(
      //   "axelar:" +
      //     axelarAddress?.bech32Address +
      //     ", osmosis:" +
      //     osmosisAddress?.bech32Address
      // );

      // props.setNewValue(
      //   user.verifiedCredentials.map(
      //     (wallet) => wallet.walletName + ":" + wallet.address
      //   )
      // );
    }
    // else {
    //   console.log("no verified credentials");
    // }
  }, [user]);

  return <></>;
};

export default DynamicAppUser;
