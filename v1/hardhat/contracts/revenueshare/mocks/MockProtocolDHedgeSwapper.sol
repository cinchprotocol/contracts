// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IYieldSourceDHedge.sol";

contract MockProtocolDHedgeSwapper {
    function withdraw(
        address pool,
        uint256 fundTokenAmount,
        IERC20 withdrawalAsset,
        uint256 expectedAmountOut
    ) external {
        IERC20(pool).transferFrom(msg.sender, address(this), fundTokenAmount);
        IYieldSourceDHedge(pool).withdrawTo(msg.sender, fundTokenAmount);
    }
}
