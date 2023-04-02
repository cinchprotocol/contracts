// https://github.com/wighawag/hardhat-deploy
// Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy

const hre = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const mockERC20 = await deploy("MockERC20", {
    from: deployer,
    log: true,
  });
};
module.exports.tags = ['RevenueShareVaultMock'];