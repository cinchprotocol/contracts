// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
     * @dev whenNotPaused
     * @dev nonReentrant
     * @dev if _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)
     * @param shares amount of shares to burn and redeem assets
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * @param referral address of the partner referral
     * @return assets amount of assets received
     */
    function redeemWithReferral(
        uint256 shares,
        address receiver,
        address sharesOwner,
        address referral
    ) public override whenNotPaused nonReentrant returns (uint256) {
        require(shares > 0, "ZERO_SHARES");
        require(
            receiver != address(0) && referral != address(0),
            "ZERO_ADDRESS"
        );
        require(
            shares <= maxRedeem(sharesOwner),
            "RevenueShareVault: max redeem exceeded"
        );
        require(
            shares <= balanceOf(sharesOwner),
            "RevenueShareVault: insufficient shares"
        );
        require(
            shares <= totalSharesByUserReferral[sharesOwner][referral],
            "RevenueShareVault: insufficient shares by referral"
        );

        //remove the shares from the user record first to avoid reentrancy attack
        _trackSharesInReferralRemoved(sharesOwner, referral, shares);

        if (_msgSender() != sharesOwner) {
            _spendAllowance(sharesOwner, _msgSender(), shares);
        }
        _burn(sharesOwner, shares);

        emit RedeemWithReferral(
            _msgSender(),
            receiver,
            sharesOwner,
            0,
            shares,
            referral
        );
        return 0;
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[20] private __gap;
}
