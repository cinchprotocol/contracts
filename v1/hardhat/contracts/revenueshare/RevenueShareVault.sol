// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./GeneralYieldSourceAdapter.sol";
import "./GeneralRevenueShareLogic.sol";
import "./security/DepositPausableUpgradeable.sol";

/**
 * @title RevenueShareVault
 * @notice Contract allows deposits and Withdrawals to Yield source product
 * @dev Should be deployed per yield source pool/vault
 * @dev This contract does not intend to confront to the whole ERC4626 standard
 */
contract RevenueShareVault is ERC20Upgradeable, OwnableUpgradeable, PausableUpgradeable, DepositPausableUpgradeable, ReentrancyGuardUpgradeable, GeneralYieldSourceAdapter, GeneralRevenueShareLogic {
    using MathUpgradeable for uint256;

    //TODO: doc
    event Withdraw(address indexed sender, address indexed receiver, address indexed sharesOwner, uint256 assets, uint256 shares);

    /// @dev Emitted when user deposit with referral
    event DepositWithReferral(address caller, address receiver, uint256 assets, uint256 shares, address indexed referral);
    /// @dev Emitted when user redeem with referral
    event RedeemWithReferral(address caller, address receiver, address sharesOwner, uint256 assets, uint256 shares, address indexed referral);

    /// @dev Underlying asset of the vault
    address asset;
    /// @dev Total asset deposit processed
    uint256 public totalAssetDepositProcessed;

    /**
     * @notice vault initializer
     * @param asset_ underneath asset, which should match the asset of the yield source vault
     * @param name_ ERC20 name of the vault shares token
     * @param symbol_ ERC20 symbol of the vault shares token
     * @param yieldSourceVault_ vault address of yield source
     * @param yieldSourceSwapper_ swapper address of yield source
     * @param cinchPerformanceFeePercentage_ Cinch performance fee percentage with 2 decimals
     */
    function initialize(address asset_, string calldata name_, string calldata symbol_, address yieldSourceVault_, address yieldSourceSwapper_, uint256 cinchPerformanceFeePercentage_) public initializer {
        __Ownable_init();
        __Pausable_init();
        __DepositPausable_init();
        __ERC20_init(name_, symbol_);
        __GeneralYieldSourceAdapter_init(yieldSourceVault_, yieldSourceSwapper_);
        __GeneralRevenueShareLogic_init(cinchPerformanceFeePercentage_);
        asset = asset_;
    }

    /*//////////////////////////////////////////////////////////////
                                ERC4626
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deposit assets to the vault
     * @dev See {IERC4626-deposit}
     * @dev depositWithReferral(assets, receiver, receiver)
     * @param assets amount of assets to deposit
     * @param receiver address to receive the shares
     */
    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        return depositWithReferral(assets, receiver, receiver);
    }

    /**
     * @notice Deposit assets to the vault with referral
     * @dev Transfer assets to this contract, then deposit into yield source vault, and mint shares to receiver
     * @dev See {IERC4626-deposit}
     * @dev whenNotPaused whenDepositNotPaused nonReentrant
     * @dev emit Deposit
     * @param assets amount of assets to deposit
     * @param receiver address to receive the shares
     * @param referral address of the partner referral
     * @return shares amount of shares received
     */
    function depositWithReferral(uint256 assets, address receiver, address referral) public virtual whenNotPaused whenDepositNotPaused nonReentrant returns (uint256) {
        require(assets > 0, "ZERO_ASSETS");
        require(receiver != address(0) && referral != address(0), "ZERO_ADDRESS");
        require(assets <= maxDeposit(receiver), "RevenueShareVault: max deposit exceeded");

        // Transfer assets to this vault first, assuming it was approved by the sender
        SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(asset), _msgSender(), address(this), assets);

        // Deposit assets to yield source vault
        uint256 shares = _depositToYieldSourceVault(asset, assets);

        // Mint the shares from this vault according to the number of shares received from yield source vault
        _mint(receiver, shares);
        _trackSharesInReferralAdded(receiver, referral, shares);
        totalAssetDepositProcessed += assets;
        emit DepositWithReferral(_msgSender(), receiver, assets, shares, referral);

        return shares;
    }

    //TODO: doc
    function maxRedeem(address sharesOwner_) public view virtual returns (uint256) {
        return balanceOf(sharesOwner_);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(address caller, address receiver, address sharesOwner_, uint256 assets, uint256 shares) internal virtual {
        if (caller != sharesOwner_) {
            _spendAllowance(sharesOwner_, caller, shares);
        }

        // If _asset is ERC777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(sharesOwner_, shares);
        SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(asset), receiver, assets);

        emit Withdraw(caller, receiver, sharesOwner_, assets, shares);
    }

    /**
     * @notice IERC4626-mint function is not supported by default, unless child contract overrides this function
     * @dev See {IERC4626-mint}
     * param shares amount of shares to mint
     * param receiver address to receive the shares
     * @return amount of assets consumed
     */
    /*
    function mint(uint256, address) public virtual returns (uint256) {
        require(false, "RevenueShareVault: not supported");
    }
    */

    /**
     * @notice Redeem assets with vault shares
     * @dev See {IERC4626-redeem}
     * @param shares amount of shares to burn and redeem assets
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * @return assets amount of assets received
     */
    function redeem(uint256 shares, address receiver, address sharesOwner) public virtual returns (uint256) {
        return redeemWithReferral(shares, receiver, sharesOwner, sharesOwner);
    }

    /**
     * @notice Redeem assets with vault shares and referral
     * @dev See {IERC4626-redeem}
     * @dev whenNotPaused
     * @dev nonReentrant
     * @dev if _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)
     * @param shares amount of shares to burn and redeem assets
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * @param referral address of the partner referral
     * @return assets amount of assets received
     */
    function redeemWithReferral(uint256 shares, address receiver, address sharesOwner, address referral) public virtual whenNotPaused nonReentrant returns (uint256) {
        require(shares > 0, "ZERO_SHARES");
        require(receiver != address(0) && referral != address(0), "ZERO_ADDRESS");
        require(shares <= maxRedeem(sharesOwner), "RevenueShareVault: max redeem exceeded");
        require(shares <= totalSharesByUserReferral[sharesOwner][referral], "RevenueShareVault: insufficient shares by referral");

        //remove the shares from the user record first to avoid reentrancy attack
        _trackSharesInReferralRemoved(sharesOwner, referral, shares);

        uint256 assets = _redeemFromYieldSourceVault(shares);
        _withdraw(_msgSender(), receiver, sharesOwner, assets, shares);
        emit RedeemWithReferral(_msgSender(), receiver, sharesOwner, assets, shares, referral);
        return assets;
    }

    /**
     * @notice IERC4626-withdraw function is not supported by default, unless child contract overrides this function
     * @dev See {IERC4626-withdraw}
     * param assets target amount of assets to be withdrawn
     * param receiver address to receive the assets
     * param sharesOwner address of the owner of the shares to be consumed
     * @return assets amount of assets received
     */
    /*
    function withdraw(uint256, address, address) public virtual returns (uint256) {
        require(false, "RevenueShareVault: not supported");
    }
    */

    /**
     * @dev See {IERC4626-totalAssets}
     * @return assets total amount of the underlying asset managed by this vault
     */
    function totalAssets() public view virtual returns (uint256) {
        uint256 shares = shareBalanceAtYieldSourceOf(address(this));
        return _convertYieldSourceSharesToAssets(shares, MathUpgradeable.Rounding.Down);
    }

    /**
     * @return assets maximum asset amounts that can be deposited
     */
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @return assets maximum asset amounts that can be withdrawn
     */
    /*
    function maxWithdraw(address _owner) public view virtual override returns (uint256) {
        return convertToAssets(balanceOf(_owner));
    }
    */

    /**
     * @notice Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param assets amount of assets to be converted to shares
     * @param rounding rounding mode
     * @return shares amount of shares that would be converted from assets
     */
    /*
    function _convertToShares(uint256 assets, MathUpgradeable.Rounding rounding) internal view virtual returns (uint256) {
        return _convertAssetsToYieldSourceShares(assets, rounding);
    }
    */

    /**
     * @notice Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param shares amount of shares to be converted to assets
     * @param rounding rounding mode
     * @return assets amount of assets that would be converted from shares
     */
    /*
    function _convertToAssets(uint256 shares, MathUpgradeable.Rounding rounding) internal view virtual returns (uint256) {
        return _convertYieldSourceSharesToAssets(shares, rounding);
    }
    */

    /*//////////////////////////////////////////////////////////////
                            YIELD SOURCE
    //////////////////////////////////////////////////////////////*/

    /**
     * @param account target account address
     * @param referral target referral address
     * @return assets amount of assets that the user has deposited to the vault
     */
    function assetBalanceAtYieldSourceOf(address account, address referral) public view virtual override returns (uint256) {
        return _convertYieldSourceSharesToAssets(totalSharesByUserReferral[account][referral], MathUpgradeable.Rounding.Down);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Pause the contract.
     * @dev onlyOwner
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the contract.
     * @dev onlyOwner
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[19] private __gap;
}
