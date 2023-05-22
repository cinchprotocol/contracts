// https://github.com/wighawag/hardhat-deploy
// Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy

const hre = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    //https://optimistic.etherscan.io/token/0x7f5c764cbc14f9669b88837ca1490cca17c31607
    const usdcAddress = "0x7F5c764cBc14f9669B88837ca1490cCa17c31607";
    //https://optimistic.etherscan.io/address/0x49bf093277bf4dde49c48c6aa55a3bda3eedef68
    //https://app.dhedge.org/vault/0x49bf093277bf4dde49c48c6aa55a3bda3eedef68
    const torosUSDmnyAddress = "0x49bF093277Bf4dDe49c48c6AA55A3bDA3eeDEF68";
    const cinchPerformanceFeePercentage = ethers.utils.parseUnits("10", 2);

    const vault = await deploy('RevenueShareVaultDHedge', {
        from: deployer,
        proxy: {
            owner: deployer,
            proxyContract: 'OpenZeppelinTransparentProxy',
            execute: {
                init: {
                    methodName: 'initialize', // method to be executed when the proxy is deployed
                    args: [
                        usdcAddress,
                        "CinchRevenueShareDHedgeTorosUSDmny",
                        "crsDTU",
                        torosUSDmnyAddress,
                        cinchPerformanceFeePercentage,
                    ],
                }
            },
        },
        log: true
    });
};
module.exports.tags = ['RevenueShareVaultDHedgeTorosUSDmny'];