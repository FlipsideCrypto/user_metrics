import { reactShinyInput } from "reactR";
import { DynamicContextProvider, DynamicWidget } from "@dynamic-labs/sdk-react-core";
import { FlowWalletConnectors } from "@dynamic-labs/flow";

import DynamicAppUser from "./DynamicAppUser.jsx";

// Access the Dynamic Configuration Dashboard at:
// https://app.dynamic.xyz/dashboard/configurations
// 
// You must have a valid invite, but can just access this with your email if 
// an invite has been sent.

const TextInput = ({ configuration, value, setValue }) => {
  return (
    <DynamicContextProvider
      settings={{
        appName: "FlowScored",
        environmentId: "c6ef9d8c-6b8d-441a-9f67-72b728cef538", // DANGEROUS: Live environment
        walletConnectors: [FlowWalletConnectors],
        eventsCallbacks: {
          onAuthSuccess: (args) => {
            console.log("onAuthSuccess was called", args);
            if (args?.isAuthenticated) {
              setValue(
                args?.user?.verifiedCredentials?.map(
                  (wallet) => wallet.walletName + ":" + wallet.address
                )
              );
            }
          },
          onLinkSuccess: (args) => {
            console.log("onLinkSuccess was called", args);
            if (args?.isAuthenticated) {
              setValue(
                args?.user?.verifiedCredentials?.map(
                  (wallet) => wallet.walletName + ":" + wallet.address
                )
              );
            }
          },
        },
      }}
    >
      <DynamicWidget innerButtonComponent='Connect your wallets' />

      <DynamicAppUser setNewValue={setValue} />
    </DynamicContextProvider>
  );
};

reactShinyInput(".dynamic_button", "dynamicWidget.dynamic_button", TextInput);