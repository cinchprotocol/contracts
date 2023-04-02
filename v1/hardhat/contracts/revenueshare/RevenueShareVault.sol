// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./GeneralYieldSourceAdapter.sol";
import "./GeneralRevenueShareLogic.sol";
import "./security/DepositPausableUpgradeable.sol";

/**
 * @title RevenueShareVault
 * @notice Contract allows deposits and Withdrawals to Yield source product
 * @dev Should be deployed per yield source pool/vault
 * @dev ERC4626 based vault
 */
contract RevenueShareVault is
    ERC4626Upgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    DepositPausableUpgradeable,
    ReentrancyGuardUpgradeable,
    GeneralYieldSourceAdapter,
    GeneralRevenueShareLogic
{
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /// @dev Emitted when user deposit with referral
    event DepositWithReferral(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares,
        address indexed referral
    );
    /// @dev Emitted when user redeem with referral
    event RedeemWithReferral(
        address caller,
        address receiver,
        address sharesOwner,
        uint256 assets,
        uint256 shares,
        address indexed referral
    );

    /// @dev Total asset deposit processed
    uint256 public totalAssetDepositProcessed;

    /**
     * @notice vault initializer
     * @param asset_ underneath asset, which should match the asset of the yield source vault
     * @param name ERC20 name of the vault shares token
     * @param symbol ERC20 symbol of the vault shares token
     * @param yieldSourceVault_ vault address of yield source
     * @param yieldSourceSwapper_ swapper address of yield source
     * @param cinchPerformanceFeePercentage_ Cinch performance fee percentage with 2 decimals
     */
    function initialize(
        address asset_,
        string calldata name,
        string calldata symbol,
        address yieldSourceVault_,
        address yieldSourceSwapper_,
        uint256 cinchPerformanceFeePercentage_
    ) public initializer {
        __Ownable_init();
        __Pausable_init();
        __DepositPausable_init();
        __ERC4626_init(IERC20Upgradeable(asset_));
        __ERC20_init(name, symbol);

        __GeneralYieldSourceAdapter_init(
            yieldSourceVault_,
            yieldSourceSwapper_
        );
        __GeneralRevenueShareLogic_init(cinchPerformanceFeePercentage_);
    }

    /*//////////////////////////////////////////////////////////////
                                ERC4626
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deposit assets to the vault
     * @dev See {IERC4626-deposit}
     * @dev whenNotPaused whenDepositNotPaused
     * @dev depositWithReferral(assets, receiver, receiver)
     * @param assets amount of assets to deposit
     * @param receiver address to receive the shares
     */
    function deposit(
        uint256 assets,
        address receiver
    )
        public
        virtual
        override
        whenNotPaused
        whenDepositNotPaused
        returns (uint256)
    {
        return depositWithReferral(assets, receiver, receiver);
    }

    /**
     * @notice Deposit assets to the vault with referral
     * @dev Transfer assets to this contract, then deposit into yield source vault, and mint shares to receiver
     * @dev See {IERC4626-deposit}
     * @dev whenNotPaused whenDepositNotPaused
     * @dev emit Deposit
     * @param assets amount of assets to deposit
     * @param receiver address to receive the shares
     * @param referral address of the partner referral
     * @return shares amount of shares received
     */
    function depositWithReferral(
        uint256 assets,
        address receiver,
        address referral
    ) public virtual whenNotPaused whenDepositNotPaused returns (uint256) {
        require(assets > 0, "ZERO_ASSETS");
        require(
            receiver != address(0) && referral != address(0),
            "ZERO_ADDRESS"
        );
        require(
            assets <= maxDeposit(receiver),
            "RevenueShareVault: max deposit exceeded"
        );

        // Transfer assets to this vault first, assuming it was approved by the sender
        SafeERC20Upgradeable.safeTransferFrom(
            IERC20Upgradeable(asset()),
            _msgSender(),
            address(this),
            assets
        );

        // Deposit assets to yield source vault
        uint256 shares = _depositToYieldSourceVault(asset(), assets);

        // Mint the shares from this vault according to the number of shares received from yield source vault
        _mint(receiver, shares);
        _trackSharesInReferralAdded(receiver, referral, shares);
        totalAssetDepositProcessed += assets;
        emit DepositWithReferral(
            _msgSender(),
            receiver,
            assets,
            shares,
            referral
        );

        return shares;
    }

    /**
     * @notice Mint shares with assets
     * @notice As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
     * @notice In this case, the shares will be minted without requiring any assets to be deposited.
     * @dev See {IERC4626-mint}
     * @dev whenNotPaused whenDepositNotPaused
     * @dev depositWithReferral(assets, receiver, receiver)
     * @param shares amount of shares to mint
     * @param receiver address to receive the shares
     * @return assets amount of assets consumed
     */
    function mint(
        uint256 shares,
        address receiver
    )
        public
        virtual
        override
        whenNotPaused
        whenDepositNotPaused
        returns (uint256)
    {
        require(
            shares <= maxMint(receiver),
            "RevenueShareVault: mint more than max"
        );
        uint256 assets = previewMint(shares);
        depositWithReferral(assets, receiver, receiver);
        return assets;
    }

    /**
     * @notice Redeem assets with vault shares
     * @dev See {IERC4626-redeem}
     * @dev whenNotPaused
     * @param shares amount of shares to burn and redeem assets
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
     * @return assets amount of assets received
     */
    function redeem(
        uint256 shares,
        address receiver,
        address sharesOwner
    ) public virtual override whenNotPaused returns (uint256) {
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
    function redeemWithReferral(
        uint256 shares,
        address receiver,
        address sharesOwner,
        address referral
    ) public virtual whenNotPaused nonReentrant returns (uint256) {
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

        uint256 assets = _redeemFromYieldSourceVault(shares);
        _withdraw(_msgSender(), receiver, sharesOwner, assets, shares);
        emit RedeemWithReferral(
            _msgSender(),
            receiver,
            sharesOwner,
            assets,
            shares,
            referral
        );
        return assets;
    }

    /**
     * @notice Withdraw a specific amount of assets to be redeemed with vault shares
     * @dev See {IERC4626-withdraw}
     * @dev whenNotPaused
     * @dev redeem
     * @param assets target amount of assets to be withdrawn
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed
     * @return assets amount of assets received
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address sharesOwner
    ) public virtual override whenNotPaused returns (uint256) {
        uint256 shares = convertToShares(assets);
        return redeem(shares, receiver, sharesOwner);
    }

    /**
     * @notice Withdraw a specific amount of assets to be redeemed with vault shares and referral
     * @dev See {IERC4626-withdraw}
     * @dev whenNotPaused
     * @param assets target amount of assets to be withdrawn
     * @param receiver address to receive the assets
     * @param sharesOwner address of the owner of the shares to be consumed
     * @param referral address of the partner referral
     * @return assets amount of assets received
     */
    function withdrawWithReferral(
        uint256 assets,
        address receiver,
        address sharesOwner,
        address referral
    ) public virtual whenNotPaused returns (uint256) {
        uint256 shares = convertToShares(assets);
        return redeemWithReferral(shares, receiver, sharesOwner, referral);
    }

    /**
     * @dev See {IERC4626-totalAssets}
     * @return assets total amount of the underlying asset managed by this vault
     */
    function totalAssets() public view virtual override returns (uint256) {
        uint256 shares = shareBalanceAtYieldSourceOf(address(this));
        return
            _convertYieldSourceSharesToAssets(
                shares,
                MathUpgradeable.Rounding.Down
            );
    }

    /**
     * @return assets maximum asset amounts that can be deposited
     */
    function maxDeposit(
        address
    ) public view virtual override returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @return assets maximum asset amounts that can be withdrawn
     */
    function maxWithdraw(
        address _owner
    ) public view virtual override returns (uint256) {
        return convertToAssets(balanceOf(_owner));
    }

    /**
     * @notice Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param assets amount of assets to be converted to shares
     * @param rounding rounding mode
     * @return shares amount of shares that would be converted from assets
     */
    function _convertToShares(
        uint256 assets,
        MathUpgradeable.Rounding rounding
    ) internal view virtual override returns (uint256) {
        return _convertAssetsToYieldSourceShares(assets, rounding);
    }

    /**
     * @notice Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met
     * @dev See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}
     * @param shares amount of shares to be converted to assets
     * @param rounding rounding mode
     * @return assets amount of assets that would be converted from shares
     */
    function _convertToAssets(
        uint256 shares,
        MathUpgradeable.Rounding rounding
    ) internal view virtual override returns (uint256) {
        return _convertYieldSourceSharesToAssets(shares, rounding);
    }

    /*//////////////////////////////////////////////////////////////
                            YIELD SOURCE
    //////////////////////////////////////////////////////////////*/

    /**
     * @param account target account address
     * @param referral target referral address
     * @return assets amount of assets that the user has deposited to the vault
     */
    function assetBalanceAtYieldSourceOf(
        address account,
        address referral
    ) public view virtual override returns (uint256) {
        return
            _convertYieldSourceSharesToAssets(
                totalSharesByUserReferral[account][referral],
                MathUpgradeable.Rounding.Down
            );
    }

    function totalUserShareBalanceAtYieldSourceInReferralSet()
        external
        view
        virtual
        returns (uint256 shares)
    {
        address[] memory referrals = _referralSet.values();
        for (uint256 i = 0; i < referrals.length; i++) {
            address referral = referrals[i];
            address[] memory users = _userSetByReferral[referral].values();
            for (uint256 j = 0; j < users.length; j++) {
                address user = users[j];
                shares += shareBalanceAtYieldSourceOf(user);
            }
        }
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