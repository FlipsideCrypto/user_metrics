import { useDynamicContext } from "@dynamic-labs/sdk-react";
import { Button } from "reactstrap";
import { useEffect } from "react";

const DynamicAppUser = (props) => {
  const { user } = useDynamicContext();

  // const provider = useCosmosProvider();

  useEffect(async () => {
    // console.log("user", JSON.stringify(user, null, 2));
    // console.log("user?.verifiedCredentials", user?.verifiedCredentials);
    if (user?.verifiedCredentials) {
      // console.log(
      //   "ok then ",
      //   user.verifiedCredentials.map(
      //     (wallet) => wallet.walletName + ":" + wallet.address
      //   )
      // );

      await window?.keplr?.enable("axelar-dojo-1");
      let resp = await window.keplr.getKey("axelar-dojo-1");
      console.log("address", resp?.bech32Address);

      props.setNewValue("axelar" + ":" + resp?.bech32Address);

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
