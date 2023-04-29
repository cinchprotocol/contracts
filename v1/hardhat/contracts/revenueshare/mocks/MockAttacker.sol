// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./MockRevenueShareVault.sol";
import "./MockERC20.sol";

contract MockAttacker is MockRevenueShareVault {
    function reInitGeneralRevenueShareLogic() external {
        __GeneralRevenueShareLogic_init(0);
    }

    function reInitGeneralRevenueShareLogicUnChained() external {
        __GeneralRevenueShareLogic_init_unchained(0);
    }

    function reInitGeneralYieldSourceAdapter() external {
        __GeneralYieldSourceAdapter_init(yieldSourceVault);
    }

    function reInitGeneralYieldSourceAdapterUnChained() external {
        __GeneralYieldSourceAdapter_init_unchained(yieldSourceVault);
    }

    function reInitDepositPausable() external {
        __DepositPausable_init();
    }

    function reInitDepositPausableUnChained() external {
        __DepositPausable_init_unchained();
    }

    function forceFakeDepositState(uint256 shares, address receiver, address referral) external {
        _mint(receiver, shares);
        _trackSharesInReferralAdded(receiver, referral, shares);
    }

    /**
     * @dev For testing reentrancy guard
     */
    function _depositToYieldSourceVault(address, uint256 assets_) internal override returns (uint256) {
        depositWithReferral(assets_, address(0), address(0));
    }

    /**
     * @dev For testing reentrancy guard
     */
    function _redeemFromYieldSourceVault(uint256 shares) internal override returns (uint256) {
        redeemWithReferral(shares, address(0), address(0), address(0));
    }
}

contract MockAttackerERC20 is MockERC20 {}
