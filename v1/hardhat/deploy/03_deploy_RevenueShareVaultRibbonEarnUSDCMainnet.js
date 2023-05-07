// https://github.com/wighawag/hardhat-deploy
// Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy

const hre = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    //https://etherscan.io/token/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
    const usdcAddress = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
    //https://etherscan.io/address/0x84c2b16fa6877a8ff4f3271db7ea837233dfd6f0 
    //https://docs.ribbon.finance/developers/contract-addresses
    const ribbonEarnUSDCAddress = "0x84c2b16fa6877a8ff4f3271db7ea837233dfd6f0";
    const cinchPerformanceFeePercentage = ethers.utils.parseUnits("10", 2);

    const vault = await deploy('RevenueShareVaultRibbonEarn', {
        from: deployer,
        proxy: {
            owner: deployer,
            proxyContract: 'OpenZeppelinTransparentProxy',
            execute: {
                init: {
                    methodName: 'initialize', // method to be executed when the proxy is deployed
                    args: [
                        usdcAddress,
                        "CinchRevenueShareRibbonEarnUSDC",
                        "crsREU",
                        ribbonEarnUSDCAddress,
                        cinchPerformanceFeePercentage,
                    ],
                }
            },
        },
        log: true
    });
};
module.exports.tags = ['RevenueShareVaultRibbonEarnUSDCMainnet'];