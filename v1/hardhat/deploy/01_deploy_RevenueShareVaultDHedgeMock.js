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

  const mockProtocol = await deploy("MockProtocolDHedge", {
    from: deployer,
    log: true,
    args: [mockERC20.address],
  });

  const cinchPerformanceFeePercentage = ethers.utils.parseUnits("0", 2);
  const vault = await deploy('RevenueShareVaultDHedge', {
    from: deployer,
    proxy: {
      owner: deployer,
      proxyContract: 'OpenZeppelinTransparentProxy',
      execute: {
        init: {
          methodName: 'initialize', // method to be executed when the proxy is deployed
          args: [
            mockERC20.address,
            "CinchRevenueShare",
            "CRS",
            mockProtocol.address,
            cinchPerformanceFeePercentage,
          ],
        }
      },
    },
    log: true
  });
};
module.exports.tags = ['RevenueShareVaultDHedgeMock'];