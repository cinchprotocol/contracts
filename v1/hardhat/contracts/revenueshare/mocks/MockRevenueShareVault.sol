// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../RevenueShareVault.sol";

contract MockRevenueShareVault is RevenueShareVault {
    using SafeERC20 for IERC20;

    /**
     * @dev Deposit assets to yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param asset_ The address of the ERC20 asset contract
     * @param amount_ The amount of assets to deposit
     * @return shares amount of shares received
     */
    function _depositToYieldSourceVault(address asset_, uint256 amount_) internal virtual override returns (uint256) {
        IERC20(asset_).safeIncreaseAllowance(yieldSourceVault, amount_);
        return IYieldSourceContract(yieldSourceVault).deposit(amount_, address(this));
    }

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param shares amount of shares to burn and redeem assets
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(uint256 shares) internal virtual override returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).redeem(shares, address(this), address(this));
    }

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(address account) public view virtual override returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).balanceOf(account);
    }

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares() external view virtual override returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).totalSupply();
    }
}
