// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockProtocolDHedge is ERC4626 {
    constructor(
        address asset_
    )
        ERC4626(ERC20(asset_))
        ERC20("MockProtocolDHedge", "MOCKPROTOCOLDHEDGE")
    {}

    function tokenPrice() public pure returns (uint256) {
        return 1;
    }

    /// @notice Deposit funds into the pool
    /// @dev https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L275
    /// asset_ Address of the token
    /// @param amount_ Amount of tokens to deposit
    /// @return liquidityMinted Amount of liquidity minted
    function depositFor(
        address recipient_,
        address, // asset_
        uint256 amount_
    ) external returns (uint256 liquidityMinted) {
        _deposit(_msgSender(), recipient_, amount_, amount_);
        liquidityMinted = amount_;
    }

    /// @notice Withdraw assets based on the fund token amount
    /// @dev https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L364
    /// @param recipient_ the receipient
    /// @param fundTokenAmount_ the fund token amount
    function withdrawTo(address recipient_, uint256 fundTokenAmount_) external {
        _withdraw(
            _msgSender(),
            recipient_,
            _msgSender(),
            fundTokenAmount_,
            fundTokenAmount_
        );
    }
}
