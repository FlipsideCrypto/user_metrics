import { reactShinyInput } from "reactR";
import { Button } from "reactstrap";
import { DynamicContextProvider, DynamicWidget } from "@dynamic-labs/sdk-react";

function ActionButton() {
  return (
    <DynamicContextProvider
      settings={{
        appName: "Example App",
        multiWallet: true,
        appLogoUrl:
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Examplelogo.svg",
        environmentId: "2b9c5160-2795-44c3-ab0f-ed3bbe8d126c",
      }}
    >
      <DynamicWidget />
    </DynamicContextProvider>
  );
}

reactShinyInput(".wallet_connect", "flowAttestR.wallet_connect", ActionButton);
