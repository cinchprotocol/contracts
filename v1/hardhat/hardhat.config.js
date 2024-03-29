require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
//require("@eth-optimism/hardhat-ovm");
require("solidity-docgen");

const defaultNetwork = process.env.DEFAULT_WEB3_PROVIDER || "localhost";

const dummyPriKey = "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const optimismGoerliUrl = process.env.OPTIMISM_GOERLI_URL || "https://opt-goerli.g.alchemy.com/v2/ABC";
const optimismGoerliDeployerPriKey = process.env.OPTIMISM_GOERLI_DEPLOYER_PRIVATE_KEY || dummyPriKey;
const optimismMainnetUrl = process.env.OPTIMISM_MAINNET_URL || "https://opt-mainnet.g.alchemy.com/v2/ABC";
const optimismMainnetDeployerPriKey = process.env.OPTIMISM_MAINNET_DEPLOYER_PRIVATE_KEY || dummyPriKey;
const goerliUrl = process.env.GOERLI_URL || "https://eth-goerli.g.alchemy.com/v2/ABC";
const goerliDeployerPriKey = process.env.GOERLI_DEPLOYER_PRIVATE_KEY || dummyPriKey;

const mainnetUrl = process.env.MAINNET_URL || "https://eth-mainnet.g.alchemy.com/v2/ABC";
const mainnetDeployerPriKey = process.env.MAINNET_DEPLOYER_PRIVATE_KEY || dummyPriKey;
const mainnetGwei = 30;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork,
  solidity: {
    compilers: [
      {
        version: "0.8.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    optimismGoerli: {
      url: optimismGoerliUrl,
      accounts: [optimismGoerliDeployerPriKey],
      ovm: true,
    },
    optimismMainnet: {
      url: optimismMainnetUrl,
      accounts: [optimismMainnetDeployerPriKey],
      ovm: true,
    },
    goerli: {
      url: goerliUrl,
      accounts: [goerliDeployerPriKey],
    },
    mainnet: {
      url: mainnetUrl,
      accounts: [mainnetDeployerPriKey],
      gasPrice: mainnetGwei * 1000000000,
    }
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
  },
};
