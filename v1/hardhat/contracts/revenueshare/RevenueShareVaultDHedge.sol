// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./RevenueShareVault.sol";
import "./interfaces/IYieldSourceDHedge.sol";

contract RevenueShareVaultDHedge is RevenueShareVault {
    using MathUpgradeable for uint256;
    using SafeERC20 for IERC20;

    /// @dev Yield source swapper address
    address public yieldSourceSwapper;

    /**
     * @notice vault initializer
     * @param asset_ underneath asset, which should match the asset of the yield source vault
     * @param name_ ERC20 name of the vault shares token
     * @param symbol_ ERC20 symbol of the vault shares token
     * @param yieldSourceVault_ vault address of yield source
     * @param cinchPerformanceFeePercentage_ Cinch performance fee percentage with 2 decimals
     * @param yieldSourceSwapper_ swapper address of yield source
     */
    function initialize(address asset_, string calldata name_, string calldata symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_, address yieldSourceSwapper_) public initializer {
        require(asset_ != address(0) && yieldSourceVault_ != address(0) && yieldSourceSwapper_ != address(0), "ZERO_ADDRESS");
        __RevenueShareVault_init(asset_, name_, symbol_, yieldSourceVault_, cinchPerformanceFeePercentage_);
        yieldSourceSwapper = yieldSourceSwapper_;
    }

    /**
     * @notice Redeem assets with vault shares and referral
     * @dev whenNotPaused
     * @dev nonReentrant
     * @dev if _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)
     * @param shares amount of shares to burn and redeem assets
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * @param referral address of the partner referral
     * @param expectedAmountOut expected amount of assets to be received (slippage protection)
     * @return amount of assets received
     */
    function redeemWithReferralAndExpectedAmountOut(uint256 shares, address receiver, address sharesOwner, address referral, uint256 expectedAmountOut) external virtual whenNotPaused nonReentrant returns (uint256) {
        require(shares > 0, "ZERO_SHARES");
        require(receiver != address(0) && referral != address(0), "ZERO_ADDRESS");
        require(shares <= maxRedeem(sharesOwner), "RevenueShareVault: max redeem exceeded");
        require(shares <= totalSharesByUserReferral[sharesOwner][referral], "RevenueShareVault: insufficient shares by referral");

        //remove the shares from the user record first to avoid reentrancy attack
        _trackSharesInReferralRemoved(sharesOwner, referral, shares);

        uint256 assets = _redeemFromYieldSourceVault(shares, expectedAmountOut);
        _redeem(_msgSender(), receiver, sharesOwner, assets, shares);
        emit RedeemWithReferral(_msgSender(), receiver, sharesOwner, assets, shares, referral);
        return assets;
    }

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares() external view override returns (uint256) {
        return IYieldSourceDHedge(yieldSourceVault).totalSupply();
    }

    /**
     * @notice Redeem assets with vault shares and referral
     * @dev For this integration, redeemWithReferralAndExpectedAmountOut is supported instead of redeemWithReferral
     * @dev not supported
     * shares amount of shares to burn and redeem assets
     * receiver address to receive the assets
     * sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * referral address of the partner referral
     * @return assets_ amount of assets received
     */
    /*
    function redeemWithReferral(uint256, address, address, address) public pure override returns (uint256) {
        require(false, "RevenueShareVaultDHedge: not supported");
    }
    */

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(address account) public view override returns (uint256) {
        return IYieldSourceDHedge(yieldSourceVault).balanceOf(account);
    }

    /**
     * @dev Deposit assets to yield source vault
     * @dev virtual, expected to be overridden with specific yield source vault
     * @param asset_ The address of the ERC20 asset contract
     * @param amount_ The amount of assets to deposit
     * @return shares amount of shares received
     */
    function _depositToYieldSourceVault(address asset_, uint256 amount_) internal override returns (uint256) {
        IERC20(asset_).safeIncreaseAllowance(yieldSourceVault, amount_);
        return IYieldSourceDHedge(yieldSourceVault).depositFor(address(this), asset_, amount_);
    }

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @dev _redeemFromYieldSourceVault(uint256 shares, uint256 expectedAmountOut) is used instead
     * @dev not supported
     * param shares amount of shares to burn and redeem assets
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(uint256) internal pure override returns (uint256) {
        require(false, "RevenueShareVaultDHedge: not supported");
    }

    /**
     * @dev Redeem assets with vault shares from yield source vault
     * @param shares amount of shares to burn and redeem assets
     * @param expectedAmountOut expected amount of assets to be received (slippage protection)
     * @return assets amount of assets received
     */
    function _redeemFromYieldSourceVault(uint256 shares, uint256 expectedAmountOut) internal returns (uint256) {
        uint256 assetBalance0 = IERC20(asset).balanceOf(address(this));
        IERC20(yieldSourceVault).safeIncreaseAllowance(yieldSourceSwapper, shares);
        // redeem the assets into this contract first
        IYieldSourceDHedgeSwapper(yieldSourceSwapper).withdraw(yieldSourceVault, shares, IERC20(asset), expectedAmountOut);
        uint256 assetBalance1 = IERC20(asset).balanceOf(address(this));
        return assetBalance1 - assetBalance0;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[19] private __gap;
}
