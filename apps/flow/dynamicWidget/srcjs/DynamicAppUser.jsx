import { useDynamicContext } from "@dynamic-labs/sdk-react";
import { Button } from "reactstrap";

const DynamicAppUser = (props) => {
  const { user } = useDynamicContext();

  return (
    <>
      {user ? (
        <Button
          onClick={() =>
            props.setNewValue(
              user?.verifiedCredentials?.map((wallet) => wallet.address)
            )
          }
        >
          Update Score
        </Button>
      ) : (
        <></>
      )}
    </>
  );
};

export default DynamicAppUser;
