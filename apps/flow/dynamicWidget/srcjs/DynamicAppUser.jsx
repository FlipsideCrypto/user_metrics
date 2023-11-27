import { useDynamicContext } from "@dynamic-labs/sdk-react-core";
import { useEffect } from "react";

const DynamicAppUser = (props) => {
  const { user } = useDynamicContext();

  useEffect(() => {
    console.log("user", JSON.stringify(user, null, 2));
    if (user?.verifiedCredentials) {
      props.setNewValue(
        user.verifiedCredentials.map(
          (wallet) => wallet.walletName + ":" + wallet.address
        )
      );
    }
  }, [user]);

  return <></>;
};

export default DynamicAppUser;
