// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
contract GeneralRevenueShareLogic is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using MathUpgradeable for uint256;

    // Event when a referral is added
    event RevenueShareReferralAdded(address referral);
    // Event when a referral is removed
    event RevenueShareReferralRemoved(address referral);
    // Event when revenue share is deposited, i.e. by a yield source
    event RevenueShareDeposited(address indexed assetsFrom, address asset, uint256 amount);
    // Event when revenue share is withdrawn by a referral
    event RevenueShareWithdrawn(address indexed asset, uint256 amount, address referral, address receiver);

    // Address set of all referrals
    EnumerableSetUpgradeable.AddressSet internal _referralSet;

    // Tracking total shares in all referrals, for calculating the share of each referral
    uint256 public totalSharesInReferral;
    // Partner referral address -> Total shares
    mapping(address => uint256) public totalSharesByReferral;
    // User address -> Partner referral address -> Total shares
    mapping(address => mapping(address => uint256)) public totalSharesByUserReferral;
    // asset => (referral => revenueShareBalance)
    mapping(address => mapping(address => uint256)) public revenueShareBalanceByAssetReferral;
    // asset => totalRevenueShareProcessed
    mapping(address => uint256) public totalRevenueShareProcessedByAsset;

    /**
     * @notice Add a referral to the referral set
     * @dev onlyOwner
     * @param referral_ The address of the referral to add
     */
    function addRevenueShareReferral(address referral_) external virtual onlyOwner {
        require(referral_ != address(0), "GeneralRevenueShare: referral cannot be zero address");
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
        require(referral_ != address(0), "GeneralRevenueShare: referral cannot be zero address");
        require(_referralSet.contains(referral_), "GeneralRevenueShare: referral does not exist");
        _referralSet.remove(referral_);

        emit RevenueShareReferralRemoved(referral_);
    }

    /**
     * @notice Getter for the cinchPxPayeeSet
     * @return referrals The array of referrals
     */
    function getRevenueShareReferralSet() external view returns (address[] memory referrals)
    {
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
     * @dev The amount will be splitted among referrals according to their shares ratio
     * @dev whenNotPaused
     * @param assetsFrom_ The address of the asset owner that the deposit will be taken from
     * @param asset_ The address of the asset to be deposited
     * @param amount_ The amount of asset to be deposited
     */
    function depositToRevenueShare(address assetsFrom_, address asset_, uint256 amount_) external virtual whenNotPaused { 
        require(assetsFrom_ != address(0) && asset_ != address(0), "ZERO_ADDRESS");
        require(amount_ > 0, "ZERO_AMOUNT");
        require(totalSharesInReferral > 0, "NO_SHARES_IN_REFERRAL");

        // Transfer assets to this vault first, assuming it was approved by the sender
        SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(asset_), assetsFrom_, address(this), amount_);
        totalRevenueShareProcessedByAsset[asset_] += amount_;

        uint256 distributedAmount = 0;
        // Make the amount claimable among referrals according to their shares ratio
        address[] memory referrals = _referralSet.values();
        for (uint256 i = 0; i < referrals.length; i++) {
            address referral = referrals[i];
            uint256 revenueShareForReferral = amount_.mulDiv(totalSharesByReferral[referral], totalSharesInReferral, MathUpgradeable.Rounding.Down);
            revenueShareBalanceByAssetReferral[asset_][referral] += revenueShareForReferral;
            distributedAmount += revenueShareForReferral;
        }
        
        // There may be undistributed revenue share if unregistered-referrals are using this vault to deposit into the yield source
        // In this case, allocate undistributed amount to contract owner
        if (amount_ > distributedAmount) {
            uint256 undistributedAmount = amount_ - distributedAmount;
            revenueShareBalanceByAssetReferral[asset_][owner()] += undistributedAmount;
        }

        emit RevenueShareDeposited(assetsFrom_, asset_, amount_);
    }

    /**
     * @notice Withdraw asset from revenue share balance on this vault
     * @dev _msgSender() must be a referral with enough revenue share balance
     * @dev whenNotPaused
     * @dev nonReentrant
     * @param asset_ The address of the asset to be deposited
     * @param amount_ The amount of asset to be deposited
     * @param receiver_ The address of the receiver
     */
    function withdrawFromRevenueShare(address asset_, uint256 amount_, address receiver_) external virtual whenNotPaused nonReentrant {
        require(asset_ != address(0) && receiver_ != address(0), "ZERO_ADDRESS");
        require(amount_ > 0, "ZERO_AMOUNT");
        require(revenueShareBalanceByAssetReferral[asset_][_msgSender()] >= amount_, "INSUFFICIENT_SHARES_BALANCE");
        require(IERC20Upgradeable(asset_).balanceOf(address(this)) >= amount_, "INSUFFICIENT_ASSETS_BALANCE");

        // Substract the amount from the revenue share balance first, to avoid reentrancy attack
        revenueShareBalanceByAssetReferral[asset_][_msgSender()] -= amount_;

        // Transfer assets to the receiver
        SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(asset_), receiver_, amount_);

        emit RevenueShareWithdrawn(asset_, amount_, _msgSender(), receiver_);
    }
}