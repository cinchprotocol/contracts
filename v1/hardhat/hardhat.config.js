require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
//require("@eth-optimism/hardhat-ovm");

const defaultNetwork = process.env.DEFAULT_WEB3_PROVIDER || "localhost";
const optimismGoerliUrl = process.env.OPTIMISM_GOERLI_URL || "https://opt-goerli.g.alchemy.com/v2/ABC";
const optimismGoerliDeployerPriKey = process.env.OPTIMISM_GOERLI_DEPLOYER_PRIVATE_KEY || "SECRET";
const goerliUrl = process.env.GOERLI_URL || "https://eth-goerli.g.alchemy.com/v2/ABC";
const goerliDeployerPriKey = process.env.GOERLI_DEPLOYER_PRIVATE_KEY || "SECRET";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork,
  solidity: {
    compilers: [
      {
        version: "0.8.19",
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
      ovm:true,
    },
    goerli: {
      url: goerliUrl,
      accounts: [goerliDeployerPriKey],
    }
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
  },
};
