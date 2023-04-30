// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title GeneralRevenueShareLogic
 * @dev sub-contract of Cinch Vault that handles revenue share distribution
 */
abstract contract GeneralRevenueShareLogic is Initializable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using MathUpgradeable for uint256;

    /// @dev Emitted when a referral is added
    event RevenueShareReferralAdded(address referral);
    /// @dev Emitted when a referral is removed
    event RevenueShareReferralRemoved(address referral);
    /// @dev Emitted when revenue share is deposited, i.e. by a yield source
    event RevenueShareDeposited(address indexed assetsFrom, address asset, uint256 amount);
    /// @dev Emitted when revenue share is withdrawn by a referral
    event RevenueShareWithdrawn(address indexed asset, uint256 amount, address referral, address receiver);
    /// @dev Emitted when cinchPerformanceFeePercentage is updated
    event CinchPerformanceFeePercentageUpdated(uint256 feePercentage);
    /// @dev Emitted upon setTotalSharesInReferralAccordingToYieldSource
    event TotalSharesInReferralUpdated(uint256 shares_);

    /// @dev Address set of all referrals
    EnumerableSetUpgradeable.AddressSet internal _referralSet;
    /// @dev Tracking total shares in all referrals, for calculating the share of each referral
    uint256 public totalSharesInReferral;
    /// @dev Partner referral address -> Total shares
    mapping(address => uint256) public totalSharesByReferral;
    /// @dev User address -> Partner referral address -> Total shares
    mapping(address => mapping(address => uint256)) public totalSharesByUserReferral;
    /// @dev asset => (referral => revenueShareBalance)
    mapping(address => mapping(address => uint256)) public revenueShareBalanceByAssetReferral;
    /// @dev asset => totalRevenueShareProcessed
    mapping(address => uint256) public totalRevenueShareProcessedByAsset;
    /// @dev Cinch performance fee percentage with 2 decimals
    uint256 public cinchPerformanceFeePercentage;
    /// @dev Address set of all users by referral
    mapping(address => EnumerableSetUpgradeable.AddressSet) internal _userSetByReferral;

    /**
     * @notice GeneralRevenueShareLogic initializer
     * @param cinchPerformanceFeePercentage_ Cinch performance fee percentage with 2 decimals
     */
    function __GeneralRevenueShareLogic_init(uint256 cinchPerformanceFeePercentage_) internal onlyInitializing {
        __GeneralRevenueShareLogic_init_unchained(cinchPerformanceFeePercentage_);
    }

    function __GeneralRevenueShareLogic_init_unchained(uint256 cinchPerformanceFeePercentage_) internal onlyInitializing {
        cinchPerformanceFeePercentage = cinchPerformanceFeePercentage_;
    }

    /**
     * @notice Add a referral to the referral set
     * @dev onlyOwner
     * @param referral_ The address of the referral to add
     */
    function addRevenueShareReferral(address referral_) external virtual onlyOwner {
        require(referral_ != address(0), "ZERO_ADDRESS");
        require(!_referralSet.contains(referral_), "GeneralRevenueShare: referral already exists");
        _referralSet.add(referral_);
        emit RevenueShareReferralAdded(referral_);
    }

    /**
     * @notice Remove a referral from the referral set
     * @dev onlyOwner
     * @param referral_ The address of the referral to remove
     */
    function removeRevenueShareReferral(address referral_) external virtual onlyOwner {
        require(referral_ != address(0), "ZERO_ADDRESS");
        require(_referralSet.contains(referral_), "GeneralRevenueShare: referral does not exist");
        _referralSet.remove(referral_);
        emit RevenueShareReferralRemoved(referral_);
    }

    /**
     * @notice Getter for the cinchPxPayeeSet
     * @return referrals The array of referrals
     */
    function getRevenueShareReferralSet() external view returns (address[] memory referrals) {
        referrals = _referralSet.values();
    }

    /**
     * @notice For tracking the amount of shares added in referral
     * @param sharesOwner The address of the shares owner
     * @param referral The address of the referral
     * @param shares The amount of shares added
     */
    function _trackSharesInReferralAdded(address sharesOwner, address referral, uint256 shares) internal virtual {
        totalSharesByReferral[referral] += shares;
        totalSharesByUserReferral[sharesOwner][referral] += shares;
        totalSharesInReferral += shares;
        _userSetByReferral[referral].add(sharesOwner);
    }

    /**
     * @notice For tracking the amount of shares decreased in referral
     * @param sharesOwner The address of the shares owner
     * @param referral The address of the referral
     * @param shares The amount of shares decreased
     */
    function _trackSharesInReferralRemoved(address sharesOwner, address referral, uint256 shares) internal virtual {
        totalSharesByUserReferral[sharesOwner][referral] -= shares;
        totalSharesByReferral[referral] -= shares;
        totalSharesInReferral -= shares;
    }

    /**
     * @notice Deposit asset as revenue share into this vault
     * @dev The amount will be split among referrals according to their shares ratio
     * @dev whenNotPaused nonReentrant
     * @param assetsFrom_ The address of the asset owner that the deposit will be taken from
     * @param asset_ The address of the asset to be deposited
     * @param amount_ The amount of asset to be deposited
     */
    function depositToRevenueShare(address assetsFrom_, address asset_, uint256 amount_) external virtual whenNotPaused nonReentrant {
        require(assetsFrom_ != address(0) && asset_ != address(0), "ZERO_ADDRESS");
        require(amount_ > 0, "ZERO_AMOUNT");
        uint256 totalSharesInReferral_ = totalSharesInReferral;
        require(totalSharesInReferral_ > 0, "GeneralRevenueShareLogic: totalSharesInReferral is zero");

        // Transfer assets to this vault first, assuming it was approved by the sender
        SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(asset_), assetsFrom_, address(this), amount_);
        totalRevenueShareProcessedByAsset[asset_] += amount_;

        // Take Cinch performance fee from the amount
        uint256 amountAfterFee = amount_.mulDiv(10000 - cinchPerformanceFeePercentage, 10000, MathUpgradeable.Rounding.Up);

        uint256 distributedAmount = 0;
        // Make the amount claimable among referrals according to their shares ratio
        address[] memory referrals = _referralSet.values();
        for (uint256 i = 0; i < referrals.length; i++) {
            address referral = referrals[i];
            uint256 revenueShareForReferral = amountAfterFee.mulDiv(totalSharesByReferral[referral], totalSharesInReferral_, MathUpgradeable.Rounding.Down);
            revenueShareBalanceByAssetReferral[asset_][referral] += revenueShareForReferral;
            distributedAmount += revenueShareForReferral;
        }

        // If cinchPerformanceFeePercentage > 0,
        // Or there are unregistered-referrals are using this vault to deposit into the yield source
        // In both case, allocate undistributed amount to contract owner
        if (amount_ > distributedAmount) {
            uint256 undistributedAmount = amount_ - distributedAmount;
            revenueShareBalanceByAssetReferral[asset_][owner()] += undistributedAmount;
        }

        emit RevenueShareDeposited(assetsFrom_, asset_, amount_);
    }

    /**
     * @notice Withdraw asset from revenue share balance on this vault
     * @dev _msgSender() must be a referral with enough revenue share balance
     * @dev whenNotPaused nonReentrant
     * @param asset_ The address of the asset to be deposited
     * @param amount_ The amount of asset to be deposited
     * @param receiver_ The address of the receiver
     */
    function withdrawFromRevenueShare(address asset_, uint256 amount_, address receiver_) external virtual whenNotPaused nonReentrant {
        require(asset_ != address(0) && receiver_ != address(0), "ZERO_ADDRESS");
        require(amount_ > 0, "ZERO_AMOUNT");
        require(revenueShareBalanceByAssetReferral[asset_][_msgSender()] >= amount_, "GeneralRevenueShareLogic: insufficient shares balance");

        // Subtract the amount from the revenue share balance first, to avoid reentrancy attack
        revenueShareBalanceByAssetReferral[asset_][_msgSender()] -= amount_;

        emit RevenueShareWithdrawn(asset_, amount_, _msgSender(), receiver_);

        // Transfer assets to the receiver
        SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(asset_), receiver_, amount_);
    }

    /**
     * @notice Set the cinch performance fee percentage
     * @dev onlyOwner
     * @param feePercentage_ Cinch performance fee percentage with 2 decimals
     */
    function setCinchPerformanceFeePercentage(uint256 feePercentage_) external virtual onlyOwner {
        require(feePercentage_ <= 10000, "GeneralRevenueShare: invalid fee percentage");
        cinchPerformanceFeePercentage = feePercentage_;
        emit CinchPerformanceFeePercentageUpdated(feePercentage_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[18] private __gap;
}
