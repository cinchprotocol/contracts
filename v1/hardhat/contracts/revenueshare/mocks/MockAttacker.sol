// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../RevenueShareVault.sol";

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
}