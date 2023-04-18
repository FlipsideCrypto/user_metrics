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

const chains = [
  { displayName: "cosmos", chainId: "cosmoshub-4" },
  { displayName: "axelar", chainId: "axelar-dojo-1" },
  { displayName: "osmosis", chainId: "osmosis-1" },
  { displayName: "evmos", chainId: "evmos_9001-2" },
  { displayName: "injective", chainId: "injective-1" },
  { displayName: "stride", chainId: "stride-1" },
  // { displayName: "crescent", chainId: "crescent-1" },
  { displayName: "juno", chainId: "juno-1" },
  { displayName: "secret", chainId: "secret-4" },
  { displayName: "stargaze", chainId: "stargaze-1" },
  { displayName: "umee", chainId: "umee-1" },
  { displayName: "agoric", chainId: "agoric-3" },
  // { displayName: "kujira", chainId: "kaiyo-1" },
  { displayName: "persistence", chainId: "core-1" },
];

const TextInput = ({ configuration, value, setValue }) => {
  return (
    <DynamicContextProvider
      settings={{
        appName: "CosmoScored",
        multiWallet: true,
        shadowDOMEnabled: false,
        environmentId: "88e7cf93-cd57-4664-b5da-9682b46074e0",
        eventsCallbacks: {
          onAuthSuccess: async (args) => {
            console.log("onAuthSuccess was called", args);
            if (args?.isAuthenticated) {
              // // bech32Address;
              // // console.log("resp", JSON.stringify(resp, null, 2));

              // // await window?.keplr?.enable("axelar-dojo-1");
              // let axelarAddress = await window?.keplr?.getKey("axelar-dojo-1");
              // // console.log("axelar address", axelarAddress?.bech32Address);
              // let osmosisAddress = await window?.keplr?.getKey("osmosis-1");
              // setValue(
              //   "axelar:" +
              //     axelarAddress?.bech32Address +
              //     ", osmosis:" +
              //     osmosisAddress?.bech32Address
              // );

              let wallets = [];

              if (window?.keplr) {
                await Promise.all(
                  chains.map(async (chain) => {
                    try {
                      let address = await window.keplr.getKey(chain.chainId);
                      wallets.push(
                        chain.displayName + ":" + address?.bech32Address
                      );
                      console.log(wallets);
                    } catch (err) {
                      console.log("error", err);
                    }
                  })
                );

                // also add evm chains
                args?.user?.verifiedCredentials?.map((wallet) => {
                  wallets.push(wallet.walletName + ":" + wallet.address);
                });

                setValue(wallets.toString());
              }
            }
          },
          onLinkSuccess: async (args) => {
            console.log("onLinkSuccess was called", args);
            if (args?.isAuthenticated) {
              let wallets = [];
              if (window?.keplr) {
                await Promise.all(
                  chains.map(async (chain) => {
                    try {
                      let address = await window.keplr.getKey(chain.chainId);
                      wallets.push(
                        chain.displayName + ":" + address?.bech32Address
                      );
                      console.log(wallets);
                    } catch (err) {
                      console.log("error", err);
                    }
                  })
                );
                // also add evm chains
                args?.user?.verifiedCredentials?.map((wallet) => {
                  wallets.push(wallet.walletName + ":" + wallet.address);
                });

                setValue(wallets.toString());
              }
              // let axelarAddress = await window?.keplr?.getKey("axelar-dojo-1");
              // // console.log("axelar address", axelarAddress?.bech32Address);
              // let osmosisAddress = await window?.keplr?.getKey("osmosis-1");
              // setValue(
              //   "axelar:" +
              //     axelarAddress?.bech32Address +
              //     ", osmosis:" +
              //     osmosisAddress?.bech32Address
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
      <DynamicAppUser setNewValue={setValue} chains={chains} />
    </DynamicContextProvider>
  );
};

reactShinyInput(".dynamic_button", "dynamicWidget.dynamic_button", TextInput);
