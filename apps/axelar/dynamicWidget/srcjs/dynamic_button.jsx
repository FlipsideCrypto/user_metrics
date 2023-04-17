import { reactShinyInput } from "reactR";
import { DynamicContextProvider, DynamicWidget } from "@dynamic-labs/sdk-react";
import DynamicAppUser from "./DynamicAppUser.jsx";
// import { useCosmosProvider } from "./useCosmosProvider.jsx";

// Add this
// if (typeof window !== "undefined") {
//   window.global = globalThis;
//   Object.assign(window, { Buffer });
//   Object.assign(window, { crypto });
//   Object.assign(window, { Stream });
// }

const TextInput = ({ configuration, value, setValue }) => {
  return (
    <DynamicContextProvider
      settings={{
        appName: "CosmoScored",
        multiWallet: true,
        environmentId: "88e7cf93-cd57-4664-b5da-9682b46074e0",
        eventsCallbacks: {
          onAuthSuccess: async (args) => {
            console.log("onAuthSuccess was called", args);

            if (args?.isAuthenticated) {
              // bech32Address;
              // console.log("resp", JSON.stringify(resp, null, 2));

              await window?.keplr?.enable("axelar-dojo-1");
              let resp = await window.keplr.getKey("axelar-dojo-1");
              console.log("address", resp?.bech32Address);

              setValue("axelar" + ":" + resp?.bech32Address);

              // setValue(
              //   args?.user?.verifiedCredentials?.map(
              //     (wallet) => wallet.walletName + ":" + wallet.address
              //   )
              // );
            }
          },
          onLinkSuccess: async (args) => {
            console.log("onLinkSuccess was called", args);
            if (args?.isAuthenticated) {
              await window?.keplr?.enable("axelar-dojo-1");
              let resp = await window.keplr.getKey("axelar-dojo-1");
              console.log("address", resp?.bech32Address);

              setValue("axelar" + ":" + resp?.bech32Address);
              // setValue(
              //   args?.user?.verifiedCredentials?.map(
              //     (wallet) => wallet.walletName + ":" + wallet.address
              //   )
              // );
            }
          },
        },
        newToWeb3WalletChainMap: {
          primary_chain: "cosmos",
          wallets: {
            cosmos: "keplr",
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
