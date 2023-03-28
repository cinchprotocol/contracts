// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./RevenueShareVault.sol";

interface IYieldSourceDHedge {
    /// @notice Deposit funds into the pool
    /// @dev https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L275
    /// @param _asset Address of the token
    /// @param _amount Amount of tokens to deposit
    /// @return liquidityMinted Amount of liquidity minted
    function depositFor(
        address _recipient,
        address _asset,
        uint256 _amount
    ) external returns (uint256 liquidityMinted);

    /// @notice Withdraw assets based on the fund token amount
    /// @dev https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L364
    /// @param _fundTokenAmount the fund token amount
    function withdrawTo(address _recipient, uint256 _fundTokenAmount) external;

    /// @notice Withdraw a single asset with the fund token amount
    /// @param fundTokenAmount_ the fund token amount
    /// @param asset_ the asset address
    function withdrawSingle(uint256 fundTokenAmount_, address asset_) external;

    /// @notice Get price of the asset adjusted for any unminted manager fees
    /// @dev https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L584
    /// @dev price is in unit of USD with 18 decimals
    /// @param price A price of the asset i.e. 1289033757439016251 => 1.28 USD
    function tokenPrice() external view returns (uint256 price);

    /// @return total shares supply with 18 decimals i.e. 7454095482755680176243 => 7454.1 shares
    function totalSupply() external view returns (uint256);

    /// @return balance of shares of the account i.e. 999977130000000000 => 0.999977 shares
    function balanceOf(address account) external view returns (uint256);
}

contract RevenueShareVaultDHedge is RevenueShareVault {
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
        return
            IYieldSourceDHedge(yieldSourceVault).depositFor(
                address(this),
                asset_,
                assets_
            );
    }

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param shares amount of shares to burn and redeem assets
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(
        uint256 shares
    ) internal override returns (uint256) {
        uint256 assetBalance0 = IERC20Upgradeable(asset()).balanceOf(
            address(this)
        );
        // redeem the assets into this contract first
        IYieldSourceDHedge(yieldSourceVault).withdrawSingle(shares, asset());
        uint256 assetBalance1 = IERC20Upgradeable(asset()).balanceOf(
            address(this)
        );
        return assetBalance1 - assetBalance0;
    }

    /**
     * @notice Redeem assets with vault shares and referral
     * @dev See {IERC4626-redeem}
     * @dev whenNotPaused
     * @dev if _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)
     * @param shares amount of shares to burn and redeem assets
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * @param referral address of the partner referral
     * @return assets amount of assets received
     */
    /*
    function redeemWithReferral(
        uint256 shares,
        address receiver,
        address sharesOwner,
        address referral
    ) public override whenNotPaused returns (uint256) {
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

        // remove the shares from the user first to avoid reentrancy attack
        _trackSharesInReferralRemoved(sharesOwner, referral, shares);

        //_withdraw(_msgSender(), receiver, sharesOwner, assets, shares);
        if (_msgSender() != sharesOwner) {
            _spendAllowance(sharesOwner, _msgSender(), shares);
        }
        _burn(sharesOwner, shares);

        // this would withdraw multiple assets from the yield source vault
        IYieldSourceDHedge(yieldSourceVault).withdrawTo(receiver, shares);

        emit Withdraw(_msgSender(), receiver, sharesOwner, 0, shares);

        return 0;
    }
    */

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
        return IYieldSourceDHedge(yieldSourceVault).balanceOf(account);
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
        return IYieldSourceDHedge(yieldSourceVault).totalSupply();
    }
}
