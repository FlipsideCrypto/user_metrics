import { reactShinyInput } from "reactR";
import { DynamicContextProvider, DynamicWidget } from "@dynamic-labs/sdk-react";
import DynamicAppUser from "./DynamicAppUser.jsx";
import { Button } from "reactstrap";

const TextInput = ({ configuration, value, setValue }) => {
  return (
    <DynamicContextProvider
      settings={{
        appName: "Example App",
        multiWallet: true,
        appLogoUrl:
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Examplelogo.svg",
        environmentId: "2b9c5160-2795-44c3-ab0f-ed3bbe8d126c",
        eventsCallbacks: {
          onAuthSuccess: (args) => {
            console.log("onAuthSuccess was called", args);
            if (args?.isAuthenticated) {
              setValue(addresses.map((wallet) => wallet.address));
            }
          },
          onLinkSuccess: (args) => {
            console.log("onLinkSuccess was called", args);
            if (args?.isAuthenticated) {
              setValue(addresses.map((wallet) => wallet.address));
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
