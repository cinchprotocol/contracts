// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../RevenueShareVaultDHedge.sol";

contract MockRevenueShareVaultDHedgeAttacker is RevenueShareVaultDHedge {
    function forceFakeDepositState(uint256 shares, address receiver, address referral) external {
        _mint(receiver, shares);
        _trackSharesInReferralAdded(receiver, referral, shares);
    }
}
