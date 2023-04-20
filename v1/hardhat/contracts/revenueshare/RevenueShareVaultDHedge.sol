// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./RevenueShareVault.sol";
import "./interfaces/IYieldSourceDHedge.sol";

contract RevenueShareVaultDHedge is RevenueShareVault {
    using MathUpgradeable for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Deposit assets to yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param asset_ The addres of the ERC20 asset contract
     * @param assets_ The amount of assets to deposit
     * @return shares amount of shares received
     */
    function _depositToYieldSourceVault(address asset_, uint256 assets_) internal override returns (uint256) {
        IERC20(asset_).safeIncreaseAllowance(yieldSourceVault, assets_);
        return IYieldSourceDHedge(yieldSourceVault).depositFor(address(this), asset_, assets_);
    }

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param shares amount of shares to burn and redeem assets
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(uint256 shares) internal override returns (uint256) {
        uint256 expectedAmountOut = _convertYieldSourceSharesToAssets(shares, MathUpgradeable.Rounding.Down);
        uint256 assetBalance0 = IERC20Upgradeable(asset()).balanceOf(address(this));
         IERC20(yieldSourceVault).safeIncreaseAllowance(yieldSourceSwapper, shares);
        // redeem the assets into this contract first
        IYieldSourceDHedgeSwapper(yieldSourceSwapper).withdraw(yieldSourceVault, shares, IERC20(asset()), expectedAmountOut);
        uint256 assetBalance1 = IERC20Upgradeable(asset()).balanceOf(address(this));
        return assetBalance1 - assetBalance0;
    }

    /**
     * @return price share price of yield source vault
     */
    function sharePriceOfYieldSource() public view override returns (uint256) {
        return IYieldSourceDHedge(yieldSourceVault).tokenPrice();
    }

    /**
     * @notice Returns the amount of shares that the yield source vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param assets amount of assets to be converted to shares
     * @param rounding rounding mode
     * @return shares amount of shares that would be converted from assets
     */
    function _convertAssetsToYieldSourceShares(uint256 assets, MathUpgradeable.Rounding rounding) internal view override returns (uint256) {
        return assets.mulDiv(1, sharePriceOfYieldSource(), rounding);
    }

    /**
     * @notice Returns the amount of assets that the yield source vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param shares amount of shares to be converted to assets
     * @param rounding rounding mode
     * @return assets amount of assets that would be converted from shares
     */
    function _convertYieldSourceSharesToAssets(uint256 shares, MathUpgradeable.Rounding rounding) internal view override returns (uint256) {
        return shares.mulDiv(sharePriceOfYieldSource(), 1, rounding);
    }

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(address account) public view override returns (uint256) {
        return IYieldSourceDHedge(yieldSourceVault).balanceOf(account);
    }

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares() external view override returns (uint256) {
        return IYieldSourceDHedge(yieldSourceVault).totalSupply();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[20] private __gap;
}
