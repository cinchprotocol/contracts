require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');

const defaultNetwork = "localhost";

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
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
  },
};
