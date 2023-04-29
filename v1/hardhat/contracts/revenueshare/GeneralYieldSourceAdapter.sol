// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "./interfaces/IYieldSourceContract.sol";

/**
 * @title GeneralYieldSourceAdapter
 * @dev sub-contract of Revenue Share Vault, serving as the Yield Source Adapter template
 */
abstract contract GeneralYieldSourceAdapter is Initializable, OwnableUpgradeable {
    using MathUpgradeable for uint256;
    using SafeERC20 for IERC20;

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
     * @param asset_ The address of the ERC20 asset contract
     * @param amount_ The amount of assets to deposit
     * @return shares amount of shares received
     */
    function _depositToYieldSourceVault(address asset_, uint256 amount_) internal virtual returns (uint256);

    /*
    {
        IERC20(asset_).safeIncreaseAllowance(yieldSourceVault, amount_);
        return IYieldSourceContract(yieldSourceVault).deposit(amount_, address(this));
    }
    */

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param shares amount of shares to burn and redeem assets
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(uint256 shares) internal virtual returns (uint256);

    /*
    {
        return IYieldSourceContract(yieldSourceVault).redeem(shares, address(this), address(this));
    }
    */

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(address account) public view virtual returns (uint256);

    /*
    {
        return IYieldSourceContract(yieldSourceVault).balanceOf(account);
    }
    */

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares() external view virtual returns (uint256);

    /*
    {
        return IYieldSourceContract(yieldSourceVault).totalSupply();
    }
    */

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[18] private __gap;
}
