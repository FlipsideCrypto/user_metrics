import { reactShinyInput } from "reactR";
import { Button } from "reactstrap";

function ActionButton() {
  return (
    <DynamicContextProvider
      settings={{
        environmentId: "Enter your Environment ID here",
      }}
    >
      <DynamicWidget />
    </DynamicContextProvider>
  );
}

reactShinyInput(".wallet_connect", "flowAttestR.wallet_connect", ActionButton);
