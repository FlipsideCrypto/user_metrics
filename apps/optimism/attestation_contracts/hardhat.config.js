require("hardhat-gas-reporter");
require('hardhat-deploy');
require("hardhat-watcher");
require("hardhat-tracer");
require("hardhat-abi-exporter");
require("hardhat-api-builder");
require("hardhat-docgen");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

task("deploy", "Deploys the protocol")
  .addFlag("verify", "Verify the deployed contracts on Etherscan")
  .setAction(async (taskArgs, hre) => {
      // Compiling all of the contracts again just in case
      await hre.run('compile');

      const [deployer] = await ethers.getSigners();
      console.log(`✅ Connected to ${deployer.address}`);

      const chainId = await getChainId()

      const signer = deployer.address;
      const OPAttestation = "0x7787194CCA11131C0159c0AcFf7E127CF0B676ed"

      // Deploying the FlipsideAttestation router
      const FlipsideAttestation = await ethers.getContractFactory("FlipsideAttestation");
      flipAtt = await FlipsideAttestation.deploy(
        signer,
        OPAttestation,
      );
      flipAtt = await flipAtt.deployed();
      console.log("✅ Flipside Attestation Deployed.");

      flipAttDeployment = {
          "Chain ID": chainId,
          "Deployer": deployer.address,
          "Signer": signer,
          "Flipside Attestation Address": flipAtt.address,
          "Remaining ETH Balance": parseInt((await deployer.getBalance()).toString()) / 1000000000000000000,
      }
      console.table(flipAttDeployment)

      // Verifying
      if (taskArgs.verify === true && chainId != '31337') {

          // Give time for etherscan to confirm the contract before verifying.
          await new Promise(r => setTimeout(r, 30000));
          await hre.run("verify:verify", {
              address: flipAtt.address,
              constructorArguments: [
                signer,
                OPAttestation
              ],
          });
          console.log("✅ Flipside Attestation Verified.")
      }
});

module.exports = {
  solidity: {
      compilers: [
          {
              version: "0.8.17",
              settings: {
                  optimizer: { // Keeps the amount of gas used in check
                      enabled: true,
                      runs: 1000
                  }
              }
          }
      ],
  },
  gasReporter: {
      currency: 'USD',
      gasPrice: 20,
      coinmarketcap: process.env.COINMARKETCAP_API_KEY,
      showMethodSig: true,
      showTimeSpent: true,
  },
  watcher: {
      compilation: {
          tasks: ["compile"],
          files: ["./contracts"],
          verbose: true,
      },
      ci: {
          tasks: ["clean", { command: "compile", params: { quiet: true } }, { command: "test", params: { noCompile: true, testFiles: ["testfile.ts"] } }],
      }
  },
  abiExporter: {
      path: 'abis/',
      runOnCompile: true,
      clear: true,
      spacing: 2,
  },
  etherscan: {
      apiKey: {
        optimism: process.env.OPTIMISM_EXPLORER_API_KEY,
      }
  },
  defaultNetwork: "hardhat",
  networks: {
      hardhat: {
          chainId: 1337,
          gas: "auto",
          gasPrice: "auto",
          saveDeployments: false,
          mining: {
              auto: false,
              order: 'fifo',
              interval: 1500,
          }
      },
      optimism: {
          url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
          accounts: [`0x${process.env.PRIVATE_KEY}`],
          gasPrice: 5000000000, // 5 gwei
      },
      optimism_goerli: {
            url: `https://opt-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
      }
  }
};
