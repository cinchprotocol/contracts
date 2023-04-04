// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./RevenueShareVault.sol";

interface IYieldSourceRibbonEarn {
    /**
     * @notice Deposits the `asset` from msg.sender added to `creditor`'s deposit.
     * @notice Used for vault -> vault deposits on the user's behalf
     * @dev https://github.com/ribbon-finance/ribbon-v2/blob/7d8deadf8dd63273aeee105beebcb99564ad4711/contracts/vaults/RETHVault/base/RibbonVault.sol#L348
     * @param amount is the amount of `asset` to deposit
     * @param creditor is the address that can claim/withdraw deposited amount
     */
    function depositFor(uint256 amount, address creditor) external;

    /**
     * @notice Getter for returning the account's share balance including unredeemed shares
     * @param account is the account to lookup share balance for
     * @return the share balance
     */
    function shares(address account) external view returns (uint256);

    /**
     * @notice The price of a unit of share denominated in the `asset`
     */
    function pricePerShare() external view returns (uint256);

    /**
     * @notice Total supply of shares
     */
    function totalSupply() external view returns (uint256);
}

contract RevenueShareVaultRibbonEarn is RevenueShareVault {
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /**
     * @dev Deposit assets to yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param asset_ The addres of the ERC20 asset contract
     * @param assets_ The amount of assets to deposit
     * @return shares amount of shares received
     */
    function _depositToYieldSourceVault(
        address asset_,
        uint256 assets_
    ) internal override returns (uint256) {
        IERC20Upgradeable(asset_).approve(yieldSourceVault, assets_);

        uint256 shares0 = IYieldSourceRibbonEarn(yieldSourceVault).shares(
            _msgSender()
        );

        IYieldSourceRibbonEarn(yieldSourceVault).depositFor(
            assets_,
            _msgSender()
        );

        uint256 shares1 = IYieldSourceRibbonEarn(yieldSourceVault).shares(
            _msgSender()
        );

        return shares1 - shares0;
    }

    /**
     * @notice Redeem assets with vault shares and referral
     * @dev See {IERC4626-redeem}
     * @dev For this integration, because of Ribbon Earn's multiple steps withdrawal (with time delay) mechanism, this contract will not be processing the yield source's withdrawal directly, but only for burning the intenal shares for tracking the revenue share.
     * @dev when _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)
     * shares amount of shares to burn and redeem assets
     * receiver address to receive the assets
     * sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * referral address of the partner referral
     * @return assets_ amount of assets received
     */
    function redeemWithReferral(
        uint256, // shares,
        address, // receiver,
        address, // sharesOwner,
        address // referral
    ) public override returns (uint256) {
        require(false, "RevenueShareVaultRibbonEarn: not supported");
    }

    /**
     * @return price share price of yield source vault
     */
    function sharePriceOfYieldSource() public view override returns (uint256) {
        return IYieldSourceRibbonEarn(yieldSourceVault).pricePerShare();
    }

    /**
     * @notice Returns the amount of shares that the yield source vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param assets amount of assets to be converted to shares
     * @param rounding rounding mode
     * @return shares amount of shares that would be converted from assets
     */
    function _convertAssetsToYieldSourceShares(
        uint256 assets,
        MathUpgradeable.Rounding rounding
    ) internal view override returns (uint256) {
        return assets.mulDiv(1, sharePriceOfYieldSource(), rounding);
    }

    /**
     * @notice Returns the amount of assets that the yield source vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param shares amount of shares to be converted to assets
     * @param rounding rounding mode
     * @return assets amount of assets that would be converted from shares
     */
    function _convertYieldSourceSharesToAssets(
        uint256 shares,
        MathUpgradeable.Rounding rounding
    ) internal view override returns (uint256) {
        return shares.mulDiv(sharePriceOfYieldSource(), 1, rounding);
    }

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(
        address account
    ) public view override returns (uint256) {
        return IYieldSourceRibbonEarn(yieldSourceVault).shares(account);
    }

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares()
        external
        view
        override
        returns (uint256)
    {
        return IYieldSourceRibbonEarn(yieldSourceVault).totalSupply();
    }

    /**
     * @dev See {IERC4626-totalAssets}
     * @return assets total amount of the underlying asset managed by this vault
     */
    function totalAssets() public view override returns (uint256) {
        return
            _convertYieldSourceSharesToAssets(
                totalSharesInReferral,
                MathUpgradeable.Rounding.Down
            );
    }

    /**
     * @dev Since this vault does not have direct control over the Ribbon Earn vault's withdrawal, using this function to provide an accurate calculation of totalShareBalanceAtYieldSourceInReferralSet
     * @return shares_ total share balance at yield source in referral set
     */
    function totalShareBalanceAtYieldSourceInReferralSet()
        external
        view
        returns (uint256 shares_)
    {
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
     * @dev Since this vault does not have direct control over the Ribbon Earn vault's withdrawal, using this function to provide an accurate calculation of totalSharesInReferral
     * @dev onlyOwner
     */
    function setTotalSharesInReferralAccordingToYieldSource()
        external
        onlyOwner
    {
        uint256 totalSharesByReferral_;
        uint256 totalSharesInReferral_ = 0;
        address[] memory referrals = _referralSet.values();
        for (uint256 i = 0; i < referrals.length; i++) {
            totalSharesByReferral_ = 0;
            address referral = referrals[i];
            address[] memory users = _userSetByReferral[referral].values();
            for (uint256 j = 0; j < users.length; j++) {
                address user = users[j];
                totalSharesByReferral_ += shareBalanceAtYieldSourceOf(user);
            }
            totalSharesByReferral[referral] = totalSharesByReferral_;
            totalSharesInReferral_ += totalSharesByReferral_;
        }
        totalSharesInReferral = totalSharesInReferral_;
        emit TotalSharesInReferralUpdated(totalSharesInReferral_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[20] private __gap;
}
