import { useDynamicContext } from "@dynamic-labs/sdk-react";
import { Button } from "reactstrap";
import { useEffect } from "react";

const DynamicAppUser = (props) => {
  const { user } = useDynamicContext();

  useEffect(() => {
    if (user?.verifiedCredentials) {
      props.setNewValue(
        user.verifiedCredentials.map((wallet) => wallet.address)
      );
    }
  }, [user]);

  return <></>;
};

export default DynamicAppUser;
