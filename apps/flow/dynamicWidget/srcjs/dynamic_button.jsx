import { reactShinyInput } from "reactR";
import { DynamicContextProvider, DynamicWidget } from "@dynamic-labs/sdk-react";
import DynamicAppUser from "./DynamicAppUser.jsx";

const TextInput = ({ configuration, value, setValue }) => {
  return (
    <DynamicContextProvider
      settings={{
        appName: "FlowScored",
        multiWallet: true,
        environmentId: "c6ef9d8c-6b8d-441a-9f67-72b728cef538",
        eventsCallbacks: {
          onAuthSuccess: (args) => {
            console.log("onAuthSuccess was called", args);
            if (args?.isAuthenticated) {
              setValue(
                args?.user?.verifiedCredentials?.map((wallet) => wallet.address)
              );
            }
          },
          onLinkSuccess: (args) => {
            console.log("onLinkSuccess was called", args);
            if (args?.isAuthenticated) {
              setValue(
                args?.user?.verifiedCredentials?.map((wallet) => wallet.address)
              );
            }
          },
        },
      }}
    >
      <DynamicWidget />
      <DynamicAppUser setNewValue={setValue} />
    </DynamicContextProvider>
  );
};

reactShinyInput(".dynamic_button", "dynamicWidget.dynamic_button", TextInput);
