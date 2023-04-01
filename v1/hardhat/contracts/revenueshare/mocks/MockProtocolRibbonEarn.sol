// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockProtocolRibbonEarn is ERC4626 {
    constructor(
        address asset_
    )
        ERC4626(ERC20(asset_))
        ERC20("MockProtocolRibbonEarn", "MOCKPROTOCOLRIBBONEARN")
    {}

    /**
     * @notice Deposits the `asset` from msg.sender added to `creditor`'s deposit.
     * @notice Used for vault -> vault deposits on the user's behalf
     * @dev https://github.com/ribbon-finance/ribbon-v2/blob/7d8deadf8dd63273aeee105beebcb99564ad4711/contracts/vaults/RETHVault/base/RibbonVault.sol#L348
     * @param amount is the amount of `asset` to deposit
     * @param creditor is the address that can claim/withdraw deposited amount
     */
    function depositFor(uint256 amount, address creditor) external {
        _deposit(_msgSender(), creditor, amount, amount);
    }

    /**
     * @notice Getter for returning the account's share balance including unredeemed shares
     * @param account is the account to lookup share balance for
     * @return the share balance
     */
    function shares(address account) external view returns (uint256) {
        return balanceOf(account);
    }

    /**
     * @notice The price of a unit of share denominated in the `asset`
     */
    function pricePerShare() external view returns (uint256) {
        return 1;
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(
        uint256 assets,
        Math.Rounding rounding
    ) internal view override returns (uint256) {
        return assets;
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(
        uint256 shares,
        Math.Rounding rounding
    ) internal view override returns (uint256) {
        return shares;
    }
}
