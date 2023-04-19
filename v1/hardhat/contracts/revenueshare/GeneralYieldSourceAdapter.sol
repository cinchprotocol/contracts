// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "./interfaces/IYieldSourceContract.sol";

/**
 * @title GeneralYieldSourceAdapter
 * @dev sub-contract of Revenue Share Vault, serving as the Yield Source Adapter template
 */
abstract contract GeneralYieldSourceAdapter is Initializable, OwnableUpgradeable {
    using MathUpgradeable for uint256;

    /// @dev Emitted when the yieldSourceVault address is updated.
    event YieldSourceVaultUpdated(address yieldSourceVault_);

    /// @dev Yield source vault address
    address public yieldSourceVault;
    /// @dev Yield source swapper address
    address public yieldSourceSwapper;

    /**
     * @notice GeneralYieldSourceAdapter initializer
     * @param yieldSourceVault_ vault address of yield source
     * @param yieldSourceSwapper_ swapper address of yield source
     */
    function __GeneralYieldSourceAdapter_init(address yieldSourceVault_, address yieldSourceSwapper_) internal onlyInitializing {
        __GeneralYieldSourceAdapter_init_unchained(yieldSourceVault_, yieldSourceSwapper_);
    }

    function __GeneralYieldSourceAdapter_init_unchained(address yieldSourceVault_, address yieldSourceSwapper_) internal onlyInitializing {
        yieldSourceVault = yieldSourceVault_;
        yieldSourceSwapper = yieldSourceSwapper_;
    }

    /**
     * @dev Deposit assets to yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param asset_ The addres of the ERC20 asset contract
     * @param assets_ The amount of assets to deposit
     * @return shares amount of shares received
     */
    function _depositToYieldSourceVault(address asset_, uint256 assets_) internal virtual returns (uint256) {
        IERC20Upgradeable(asset_).approve(yieldSourceVault, assets_);
        return IYieldSourceContract(yieldSourceVault).deposit(assets_, address(this));
    }

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param shares amount of shares to burn and redeem assets
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(uint256 shares) internal virtual returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).redeem(shares, address(this), address(this));
    }

    /**
     * @return price share price of yield source vault
     */
    function sharePriceOfYieldSource() public view virtual returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).sharePrice();
    }

    /**
     * @notice Returns the amount of shares that the yield source vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param assets amount of assets to be converted to shares
     * @param rounding rounding mode
     * @return shares amount of shares that would be converted from assets
     */
    function _convertAssetsToYieldSourceShares(uint256 assets, MathUpgradeable.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(1, sharePriceOfYieldSource(), rounding);
    }

    /**
     * @notice Returns the amount of assets that the yield source vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param shares amount of shares to be converted to assets
     * @param rounding rounding mode
     * @return assets amount of assets that would be converted from shares
     */
    function _convertYieldSourceSharesToAssets(uint256 shares, MathUpgradeable.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(sharePriceOfYieldSource(), 1, rounding);
    }

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(address account) public view virtual returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).balanceOf(account);
    }

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares() external view virtual returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).totalSupply();
    }

    /**
     * @dev abstruct function to be implemented by specific yield source vault
     * @param account target account address
     * @param referral target referral address
     * @return assets amount of assets that the user has deposited to the vault
     */
    function assetBalanceAtYieldSourceOf(address account, address referral) public view virtual returns (uint256);

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[18] private __gap;
}
