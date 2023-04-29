// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./RevenueShareVault.sol";
import "./interfaces/IYieldSourceRibbonEarn.sol";

contract RevenueShareVaultRibbonEarn is RevenueShareVault {
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeERC20 for IERC20;

    /**
     * @dev Deposit assets to yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param asset_ The address of the ERC20 asset contract
     * @param assets_ The amount of assets to deposit
     * @return shares amount of shares received
     */
    function _depositToYieldSourceVault(address asset_, uint256 assets_) internal override returns (uint256) {
        IERC20(asset_).safeIncreaseAllowance(yieldSourceVault, assets_);
        uint256 shares0 = IYieldSourceRibbonEarn(yieldSourceVault).shares(_msgSender());
        IYieldSourceRibbonEarn(yieldSourceVault).depositFor(assets_, _msgSender());
        uint256 shares1 = IYieldSourceRibbonEarn(yieldSourceVault).shares(_msgSender());
        return shares1 - shares0;
    }

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @dev For this integration, because of Ribbon Earn's multiple steps withdrawal (with time delay) mechanism, this contract will not be processing the yield source's withdrawal directly, but only for burning the intenal shares for tracking the revenue share.
     * @dev not supported
     * param shares amount of shares to burn and redeem assets
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(uint256) internal pure override returns (uint256) {
        require(false, "RevenueShareVaultRibbonEarn: not supported");
    }

    /**
     * @notice Redeem assets with vault shares and referral
     * @dev For this integration, because of Ribbon Earn's multiple steps withdrawal (with time delay) mechanism, this contract will not be processing the yield source's withdrawal directly, but only for burning the intenal shares for tracking the revenue share.
     * @dev not supported
     * shares amount of shares to burn and redeem assets
     * receiver address to receive the assets
     * sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * referral address of the partner referral
     * @return assets_ amount of assets received
     */
    function redeemWithReferral(uint256, address, address, address) public pure override returns (uint256) {
        require(false, "RevenueShareVaultRibbonEarn: not supported");
    }

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(address account) public view override returns (uint256) {
        return IYieldSourceRibbonEarn(yieldSourceVault).shares(account);
    }

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares() external view override returns (uint256) {
        return IYieldSourceRibbonEarn(yieldSourceVault).totalSupply();
    }

    /**
     * @dev Since this vault does not have direct control over the Ribbon Earn vault's withdrawal, using this function to provide an accurate calculation of totalShareBalanceAtYieldSourceInReferralSet
     * @return shares_ total share balance at yield source in referral set
     */
    function totalShareBalanceAtYieldSourceInReferralSet() external view returns (uint256 shares_) {
        address[] memory referrals = _referralSet.values();
        for (uint256 i = 0; i < referrals.length; i++) {
            address referral = referrals[i];
            address[] memory users = _userSetByReferral[referral].values();
            for (uint256 j = 0; j < users.length; j++) {
                address user = users[j];
                shares_ += shareBalanceAtYieldSourceOf(user);
            }
        }
    }

    /**
     * @dev Since this vault does not have direct control over the Ribbon Earn vault's withdrawal, using this function to provide an accurate calculation of totalSharesInReferral if needed
     * @dev This is fesiable as this vault is targeted for institutional users, and the number of users is expected to be small
     * @dev onlyOwner
     */
    function setTotalSharesInReferralAccordingToYieldSource(address referral, address user) external onlyOwner {
        uint256 recordedUserShares_ = totalSharesByUserReferral[user][referral];
        uint256 updatedUserShares_ = shareBalanceAtYieldSourceOf(user);

        if (recordedUserShares_ > updatedUserShares_) {
            uint256 deltaShares_ = recordedUserShares_ - updatedUserShares_;
            _trackSharesInReferralRemoved(referral, user, deltaShares_);
            emit TotalSharesByUserReferralUpdated(user, referral, updatedUserShares_);
        } else if (recordedUserShares_ < updatedUserShares_) {
            uint256 deltaShares_ = updatedUserShares_ - recordedUserShares_;
            _trackSharesInReferralAdded(referral, user, deltaShares_);
            emit TotalSharesByUserReferralUpdated(user, referral, updatedUserShares_);
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[20] private __gap;
}
