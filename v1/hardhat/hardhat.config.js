require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
//require("@eth-optimism/hardhat-ovm");

const defaultNetwork = process.env.DEFAULT_WEB3_PROVIDER || "localhost";

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
      url: process.env.OPTIMISM_GOERLI_URL,
      accounts: [process.env.OPTIMISM_GOERLI_DEPLOYER_PRIVATE_KEY],
      ovm:true,
    },
    goerli: {
      url: process.env.GOERLI_URL,
      accounts: [process.env.GOERLI_DEPLOYER_PRIVATE_KEY],
    }
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
  },
};
