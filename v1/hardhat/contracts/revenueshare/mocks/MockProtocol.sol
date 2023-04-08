// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockProtocol is ERC4626 {
    constructor(address asset_) ERC4626(ERC20(asset_)) ERC20("MockProtocol", "MOCKPROTOCOL") {}

    function sharePrice() public pure returns (uint256) {
        return 1;
    }
}
