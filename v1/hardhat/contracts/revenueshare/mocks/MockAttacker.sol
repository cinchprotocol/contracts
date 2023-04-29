// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../RevenueShareVault.sol";
import "./MockERC20.sol";

contract MockAttacker is RevenueShareVault {
    function reInitGeneralRevenueShareLogic() external {
        __GeneralRevenueShareLogic_init(0);
    }

    function reInitGeneralRevenueShareLogicUnChained() external {
        __GeneralRevenueShareLogic_init_unchained(0);
    }

    function reInitGeneralYieldSourceAdapter() external {
        __GeneralYieldSourceAdapter_init(yieldSourceVault, yieldSourceSwapper);
    }

    function reInitGeneralYieldSourceAdapterUnChained() external {
        __GeneralYieldSourceAdapter_init_unchained(yieldSourceVault, yieldSourceSwapper);
    }

    function reInitDepositPausable() external {
        __DepositPausable_init();
    }

    function reInitDepositPausableUnChained() external {
        __DepositPausable_init_unchained();
    }

    /**
     * @dev For testing reentrancy guard
     */
    function _depositToYieldSourceVault(address, uint256 assets_) internal override returns (uint256) {
        depositWithReferral(assets_, address(0), address(0));
    }

    function forceFakeDepositState(uint256 shares, address receiver, address referral) external {
        _mint(receiver, shares);
        _trackSharesInReferralAdded(receiver, referral, shares);
    }

    /**
     * @dev For testing reentrancy guard
     */
    function _redeemFromYieldSourceVault(uint256 shares) internal override returns (uint256) {
        redeemWithReferral(shares, address(0), address(0), address(0));
    }

    /**
     * @param account target account address
     * @return shares yield source share balance of this vault
     */
    function shareBalanceAtYieldSourceOf(address account) public view override returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).balanceOf(account);
    }

    /**
     * @dev to be used for calculating the revenue share ratio
     * @return yieldSourceTotalShares total yield source shares supply
     */
    function getYieldSourceVaultTotalShares() external view override returns (uint256) {
        return IYieldSourceContract(yieldSourceVault).totalSupply();
    }
}

contract MockAttackerERC20 is MockERC20 {}
