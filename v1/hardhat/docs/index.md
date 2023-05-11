# Solidity API

## GeneralRevenueShareLogic

_sub-contract of Cinch Vault that handles revenue share distribution_

### totalSharesInReferral

```solidity
uint256 totalSharesInReferral
```

_Tracking total shares in all referrals, for calculating the share of each referral_

### totalSharesByReferral

```solidity
mapping(address => uint256) totalSharesByReferral
```

_Partner referral address -> Total shares_

### totalSharesByUserReferral

```solidity
mapping(address => mapping(address => uint256)) totalSharesByUserReferral
```

_User address -> Partner referral address -> Total shares_

### revenueShareBalanceByAssetReferral

```solidity
mapping(address => mapping(address => uint256)) revenueShareBalanceByAssetReferral
```

_asset => (referral => revenueShareBalance)_

### totalRevenueShareProcessedByAsset

```solidity
mapping(address => uint256) totalRevenueShareProcessedByAsset
```

_asset => totalRevenueShareProcessed_

### cinchPerformanceFeePercentage

```solidity
uint256 cinchPerformanceFeePercentage
```

_Cinch performance fee percentage with 2 decimals_

### _referralSet

```solidity
struct EnumerableSetUpgradeable.AddressSet _referralSet
```

_Address set of all referrals_

### _userSetByReferral

```solidity
mapping(address => struct EnumerableSetUpgradeable.AddressSet) _userSetByReferral
```

_Address set of all users by referral_

### CINCH_PERFORMANCE_FEE_100_PERCENT

```solidity
uint256 CINCH_PERFORMANCE_FEE_100_PERCENT
```

_Represent 100% with 2 decimal places_

### RevenueShareReferralAdded

```solidity
event RevenueShareReferralAdded(address referral)
```

_Emitted when a referral is added_

### RevenueShareReferralRemoved

```solidity
event RevenueShareReferralRemoved(address referral)
```

_Emitted when a referral is removed_

### RevenueShareDeposited

```solidity
event RevenueShareDeposited(address assetsFrom, address asset, uint256 amount)
```

_Emitted when revenue share is deposited, i.e. by a yield source_

### RevenueShareWithdrawn

```solidity
event RevenueShareWithdrawn(address asset, uint256 amount, address referral, address receiver)
```

_Emitted when revenue share is withdrawn by a referral_

### CinchPerformanceFeePercentageUpdated

```solidity
event CinchPerformanceFeePercentageUpdated(uint256 feePercentage)
```

_Emitted when cinchPerformanceFeePercentage is updated_

### TotalSharesByUserReferralUpdated

```solidity
event TotalSharesByUserReferralUpdated(address user, address referral, uint256 shares_)
```

_Emitted upon setTotalSharesInReferralAccordingToYieldSource_

### RevenueShareBalanceByAssetReferralUpdated

```solidity
event RevenueShareBalanceByAssetReferralUpdated(address asset_, address referral, uint256 shares_)
```

_Emitted upon depositToRevenueShare_

### __GeneralRevenueShareLogic_init

```solidity
function __GeneralRevenueShareLogic_init(uint256 cinchPerformanceFeePercentage_) internal
```

GeneralRevenueShareLogic initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| cinchPerformanceFeePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |

### __GeneralRevenueShareLogic_init_unchained

```solidity
function __GeneralRevenueShareLogic_init_unchained(uint256 cinchPerformanceFeePercentage_) internal
```

### depositToRevenueShare

```solidity
function depositToRevenueShare(address asset_, uint256 amount_) external virtual
```

Deposit asset as revenue share into this vault

_The amount will be split among referrals according to their shares ratio
whenNotPaused nonReentrant_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The address of the asset to be deposited |
| amount_ | uint256 | The amount of asset to be deposited |

### withdrawFromRevenueShare

```solidity
function withdrawFromRevenueShare(address asset_, uint256 amount_, address receiver_) external virtual
```

Withdraw asset from revenue share balance on this vault

__msgSender() must be a referral with enough revenue share balance
whenNotPaused nonReentrant_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The address of the asset to be deposited |
| amount_ | uint256 | The amount of asset to be deposited |
| receiver_ | address | The address of the receiver |

### addRevenueShareReferral

```solidity
function addRevenueShareReferral(address referral_) external virtual
```

Add a referral to the referral set

_onlyOwner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| referral_ | address | The address of the referral to add |

### removeRevenueShareReferral

```solidity
function removeRevenueShareReferral(address referral_) external virtual
```

Remove a referral from the referral set

_onlyOwner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| referral_ | address | The address of the referral to remove |

### setCinchPerformanceFeePercentage

```solidity
function setCinchPerformanceFeePercentage(uint256 feePercentage_) public virtual
```

Set the cinch performance fee percentage

_onlyOwner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |

### isReferralRegistered

```solidity
function isReferralRegistered(address referral_) external view returns (bool)
```

Check if the input referral is registered with this contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| referral_ | address | The address of the referral to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | isReferralRegistered True if the referral is registered |

### _trackSharesInReferralAdded

```solidity
function _trackSharesInReferralAdded(address sharesOwner, address referral, uint256 shares) internal virtual
```

For tracking the amount of shares added in referral

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| sharesOwner | address | The address of the shares owner |
| referral | address | The address of the referral |
| shares | uint256 | The amount of shares added |

### _trackSharesInReferralRemoved

```solidity
function _trackSharesInReferralRemoved(address sharesOwner, address referral, uint256 shares) internal virtual
```

For tracking the amount of shares decreased in referral

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| sharesOwner | address | The address of the shares owner |
| referral | address | The address of the referral |
| shares | uint256 | The amount of shares decreased |

## GeneralYieldSourceAdapter

_sub-contract of Revenue Share Vault, serving as the Yield Source Adapter template_

### yieldSourceVault

```solidity
address yieldSourceVault
```

_Yield source vault address_

### YieldSourceVaultUpdated

```solidity
event YieldSourceVaultUpdated(address yieldSourceVault_)
```

_Emitted when the yieldSourceVault address is updated._

### getYieldSourceVaultTotalShares

```solidity
function getYieldSourceVaultTotalShares() external view virtual returns (uint256)
```

_to be used for calculating the revenue share ratio
virtual, expected to be overridden with specific yield source vault_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | yieldSourceTotalShares total yield source shares supply |

### shareBalanceAtYieldSourceOf

```solidity
function shareBalanceAtYieldSourceOf(address account) public view virtual returns (uint256)
```

_virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | target account address |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares yield source share balance of this vault |

### __GeneralYieldSourceAdapter_init

```solidity
function __GeneralYieldSourceAdapter_init(address yieldSourceVault_) internal
```

GeneralYieldSourceAdapter initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| yieldSourceVault_ | address | vault address of yield source |

### __GeneralYieldSourceAdapter_init_unchained

```solidity
function __GeneralYieldSourceAdapter_init_unchained(address yieldSourceVault_) internal
```

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address asset_, uint256 amount_) internal virtual returns (uint256)
```

_Deposit assets to yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The address of the ERC20 asset contract |
| amount_ | uint256 | The amount of assets to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares received |

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256 shares) internal virtual returns (uint256)
```

_Redeem assets with vault shares from yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to burn and redeem assets |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

## RevenueShareVault

Contract allows deposits and Withdrawals to Yield source product

_Should be deployed per yield source pool/vault
This contract does not intend to confront to the ERC4626 standard_

### asset

```solidity
address asset
```

_Underlying asset of the vault_

### totalAssetDepositProcessed

```solidity
uint256 totalAssetDepositProcessed
```

_Total asset deposit processed_

### DepositWithReferral

```solidity
event DepositWithReferral(address caller, address receiver, uint256 assets, uint256 shares, address referral)
```

_Emitted when user deposit with referral_

### Redeem

```solidity
event Redeem(address caller, address receiver, address sharesOwner, uint256 assets, uint256 shares)
```

_Emited when user redeem_

### RedeemWithReferral

```solidity
event RedeemWithReferral(address caller, address receiver, address sharesOwner, uint256 assets, uint256 shares, address referral)
```

_Emitted when user redeem with referral_

### __RevenueShareVault_init

```solidity
function __RevenueShareVault_init(address asset_, string name_, string symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_) internal
```

RevenueShareVault initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | underneath asset, which should match the asset of the yield source vault |
| name_ | string | ERC20 name of the vault shares token |
| symbol_ | string | ERC20 symbol of the vault shares token |
| yieldSourceVault_ | address | vault address of yield source |
| cinchPerformanceFeePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |

### __RevenueShareVault_init_unchained

```solidity
function __RevenueShareVault_init_unchained(address asset_, string name_, string symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_) internal
```

### pause

```solidity
function pause() external
```

Pause the contract.

_onlyOwner_

### unpause

```solidity
function unpause() external
```

Unpause the contract.

_onlyOwner_

### depositWithReferral

```solidity
function depositWithReferral(uint256 amount, address receiver, address referral) public virtual returns (uint256)
```

Deposit assets to the vault with referral

_Transfer assets to this contract, then deposit into yield source vault, and mint shares to receiver
whenNotPaused whenDepositNotPaused nonReentrant
emit DepositWithReferral_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | amount of assets to deposit |
| receiver | address | address to receive the shares |
| referral | address | address of the partner referral |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | amount of shares received |

### redeemWithReferral

```solidity
function redeemWithReferral(uint256 shares, address receiver, address sharesOwner, address referral) public virtual returns (uint256)
```

Redeem assets with vault shares and referral

_whenNotPaused
nonReentrant
if _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to burn and redeem assets |
| receiver | address | address to receive the assets |
| sharesOwner | address | address of the owner of the shares to be consumed, require to be _msgSender() for better security |
| referral | address | address of the partner referral |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | amount of assets received |

### maxDeposit

```solidity
function maxDeposit(address) public view virtual returns (uint256)
```

For guarding the deposit function with an upper limit
param receiver address for checking the max asset amount for deposit

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | max asset amount that can be deposited |

### maxRedeem

```solidity
function maxRedeem(address sharesOwner_) public view virtual returns (uint256)
```

For guarding the redeem function with an upper limit

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| sharesOwner_ | address | owner address of the shares to be redeemed |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | balance of shares owned by the sharesOwner_ |

### _redeem

```solidity
function _redeem(address caller, address receiver, address sharesOwner, uint256 assets, uint256 shares) internal virtual
```

_redeem internal common workflow._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| caller | address | caller address |
| receiver | address | address to receive the assets |
| sharesOwner | address | address of the owner of the shares to be consumed |
| assets | uint256 | amount of assets redeemed |
| shares | uint256 | amount of shares to burn and redeem assets |

## RevenueShareVaultDHedge

### yieldSourceSwapper

```solidity
address yieldSourceSwapper
```

_Yield source swapper address_

### YieldSourceSwapperUpdated

```solidity
event YieldSourceSwapperUpdated(address yieldSourceSwapper_)
```

_Emitted when the yieldSourceSwapper address is updated._

### initialize

```solidity
function initialize(address asset_, string name_, string symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_, address yieldSourceSwapper_) public
```

vault initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | underneath asset, which should match the asset of the yield source vault |
| name_ | string | ERC20 name of the vault shares token |
| symbol_ | string | ERC20 symbol of the vault shares token |
| yieldSourceVault_ | address | vault address of yield source |
| cinchPerformanceFeePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |
| yieldSourceSwapper_ | address | swapper address of yield source |

### getYieldSourceVaultTotalShares

```solidity
function getYieldSourceVaultTotalShares() external view returns (uint256)
```

_to be used for calculating the revenue share ratio_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | yieldSourceTotalShares total yield source shares supply |

### redeemWithReferralAndExpectedAmountOut

```solidity
function redeemWithReferralAndExpectedAmountOut(uint256 shares, address receiver, address sharesOwner, address referral, uint256 expectedAmountOut) public virtual returns (uint256)
```

Redeem assets with vault shares and referral

_whenNotPaused
nonReentrant
if _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to burn and redeem assets |
| receiver | address | address to receive the assets |
| sharesOwner | address | address of the owner of the shares to be consumed, require to be _msgSender() for better security |
| referral | address | address of the partner referral |
| expectedAmountOut | uint256 | expected amount of assets to be received (slippage protection) |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | amount of assets received |

### shareBalanceAtYieldSourceOf

```solidity
function shareBalanceAtYieldSourceOf(address account) public view returns (uint256)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | target account address |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares yield source share balance of this vault |

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address asset_, uint256 amount_) internal returns (uint256)
```

_Deposit assets to yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The address of the ERC20 asset contract |
| amount_ | uint256 | The amount of assets to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares received |

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256) internal pure returns (uint256)
```

_Redeem assets with vault shares from yield source vault
_redeemFromYieldSourceVault(uint256 shares, uint256 expectedAmountOut) is used instead
not supported
param shares amount of shares to burn and redeem assets_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256 shares, uint256 expectedAmountOut) internal virtual returns (uint256)
```

_Redeem assets with vault shares from yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to burn and redeem assets |
| expectedAmountOut | uint256 | expected amount of assets to be received (slippage protection) |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

## RevenueShareVaultRibbonEarn

### initialize

```solidity
function initialize(address asset_, string name_, string symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_) public
```

vault initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | underneath asset, which should match the asset of the yield source vault |
| name_ | string | ERC20 name of the vault shares token |
| symbol_ | string | ERC20 symbol of the vault shares token |
| yieldSourceVault_ | address | vault address of yield source |
| cinchPerformanceFeePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |

### getYieldSourceVaultTotalShares

```solidity
function getYieldSourceVaultTotalShares() external view returns (uint256)
```

_to be used for calculating the revenue share ratio_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | yieldSourceTotalShares total yield source shares supply |

### setTotalSharesInReferralAccordingToYieldSource

```solidity
function setTotalSharesInReferralAccordingToYieldSource(address referral, address user) external
```

_Since this vault does not have direct control over the Ribbon Earn vault's withdrawal, using this function to provide an accurate calculation of totalSharesInReferral if needed
This is fesiable as this vault is targeted for institutional users, and the number of users is expected to be small
onlyOwner_

### shareBalanceAtYieldSourceOf

```solidity
function shareBalanceAtYieldSourceOf(address account) public view returns (uint256)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | target account address |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares yield source share balance of this vault |

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address asset_, uint256 amount_) internal returns (uint256)
```

_Deposit assets to yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The address of the ERC20 asset contract |
| amount_ | uint256 | The amount of assets to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares received |

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256) internal pure returns (uint256)
```

_Redeem assets with vault shares from yield source vault
For this integration, because of Ribbon Earn's multiple steps withdrawal (with time delay) mechanism, this contract will not be processing the yield source's withdrawal directly, but only for burning the intenal shares for tracking the revenue share.
not supported
param shares amount of shares to burn and redeem assets_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

## IYieldSourceContract

### deposit

```solidity
function deposit(uint256 assets, address receiver) external returns (uint256)
```

### redeem

```solidity
function redeem(uint256 shares, address receiver, address owner) external returns (uint256)
```

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```

## IYieldSourceDHedge

### depositFor

```solidity
function depositFor(address _recipient, address _asset, uint256 _amount) external returns (uint256 liquidityMinted)
```

Deposit funds into the pool

_https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L275_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _recipient | address |  |
| _asset | address | Address of the token |
| _amount | uint256 | Amount of tokens to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| liquidityMinted | uint256 | Amount of liquidity minted |

### withdrawTo

```solidity
function withdrawTo(address _recipient, uint256 _fundTokenAmount) external
```

Withdraw assets based on the fund token amount

_https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L364_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _recipient | address |  |
| _fundTokenAmount | uint256 | the fund token amount |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | total shares supply with 18 decimals i.e. 7454095482755680176243 => 7454.1 shares |

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | balance of shares of the account i.e. 999977130000000000 => 0.999977 shares |

## IYieldSourceDHedgeSwapper

### withdraw

```solidity
function withdraw(address pool, uint256 fundTokenAmount, contract IERC20 withdrawalAsset, uint256 expectedAmountOut) external
```

withdraw underlying value of tokens in expectedWithdrawalAssetOfUser

_Swaps the underlying pool withdrawal assets to expectedWithdrawalAssetOfUser
https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/EasySwapper/DhedgeEasySwapper.sol#L244_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| pool | address |  |
| fundTokenAmount | uint256 | the amount to withdraw |
| withdrawalAsset | contract IERC20 | must have direct pair to all pool.supportedAssets on swapRouter |
| expectedAmountOut | uint256 | the amount of value in the withdrawalAsset expected (slippage protection) |

## IYieldSourceRibbonEarn

### depositFor

```solidity
function depositFor(uint256 amount, address creditor) external
```

Deposits the `asset` from msg.sender added to `creditor`'s deposit.
Used for vault -> vault deposits on the user's behalf

_https://github.com/ribbon-finance/ribbon-v2/blob/7d8deadf8dd63273aeee105beebcb99564ad4711/contracts/vaults/RETHVault/base/RibbonVault.sol#L348_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | is the amount of `asset` to deposit |
| creditor | address | is the address that can claim/withdraw deposited amount |

### shares

```solidity
function shares(address account) external view returns (uint256)
```

Getter for returning the account's share balance including unredeemed shares

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | is the account to lookup share balance for |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the share balance |

### pricePerShare

```solidity
function pricePerShare() external view returns (uint256)
```

The price of a unit of share denominated in the `asset`

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

Total supply of shares

## IERC20Extended

_Putting this interface file inside the `mocks` folder to indicated that this is only used inside the mock contracts_

### decimals

```solidity
function decimals() external view returns (uint8)
```

## MockAttackerERC20

## MockERC20

### constructor

```solidity
constructor() public
```

### faucet

```solidity
function faucet(address to, uint256 amount) external
```

### decimals

```solidity
function decimals() public view virtual returns (uint8)
```

_Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).

Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the value {ERC20} uses, unless this function is
overridden;

NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}._

## MockProtocol

### constructor

```solidity
constructor(address asset_) public
```

### _convertToShares

```solidity
function _convertToShares(uint256 assets, enum Math.Rounding rounding) internal view virtual returns (uint256)
```

_Internal conversion function (from assets to shares) with support for rounding direction.
To mock non 1:1 share price_

### _convertToAssets

```solidity
function _convertToAssets(uint256 shares, enum Math.Rounding rounding) internal view virtual returns (uint256)
```

_Internal conversion function (from shares to assets) with support for rounding direction.
To mock non 1:1 share price_

## MockProtocolDHedge

### constructor

```solidity
constructor(address asset_) public
```

### depositFor

```solidity
function depositFor(address recipient_, address, uint256 amount_) external returns (uint256 liquidityMinted)
```

Deposit funds into the pool

_https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L275
asset_ Address of the token_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| recipient_ | address |  |
|  | address |  |
| amount_ | uint256 | Amount of tokens to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| liquidityMinted | uint256 | Amount of liquidity minted |

### withdrawTo

```solidity
function withdrawTo(address recipient_, uint256 fundTokenAmount_) external
```

Withdraw assets based on the fund token amount

_https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L364_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| recipient_ | address | the receipient |
| fundTokenAmount_ | uint256 | the fund token amount |

### _convertToShares

```solidity
function _convertToShares(uint256 assets, enum Math.Rounding rounding) internal view virtual returns (uint256)
```

_Internal conversion function (from assets to shares) with support for rounding direction.
To mock non 1:1 share price_

### _convertToAssets

```solidity
function _convertToAssets(uint256 shares, enum Math.Rounding rounding) internal view virtual returns (uint256)
```

_Internal conversion function (from shares to assets) with support for rounding direction.
To mock non 1:1 share price_

## MockProtocolDHedgeSwapper

### withdraw

```solidity
function withdraw(address pool, uint256 fundTokenAmount, contract IERC20, uint256) external
```

## MockProtocolRibbonEarn

### constructor

```solidity
constructor(address asset_) public
```

### depositFor

```solidity
function depositFor(uint256 amount, address creditor) external
```

Deposits the `asset` from msg.sender added to `creditor`'s deposit.
Used for vault -> vault deposits on the user's behalf

_https://github.com/ribbon-finance/ribbon-v2/blob/7d8deadf8dd63273aeee105beebcb99564ad4711/contracts/vaults/RETHVault/base/RibbonVault.sol#L348_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | is the amount of `asset` to deposit |
| creditor | address | is the address that can claim/withdraw deposited amount |

### shares

```solidity
function shares(address account) external view returns (uint256)
```

Getter for returning the account's share balance including unredeemed shares

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | is the account to lookup share balance for |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the share balance |

### _convertToShares

```solidity
function _convertToShares(uint256 assets, enum Math.Rounding rounding) internal pure returns (uint256)
```

_Internal conversion function (from assets to shares) with support for rounding direction.
To mock non 1:1 share price_

### _convertToAssets

```solidity
function _convertToAssets(uint256 shares_, enum Math.Rounding rounding) internal pure returns (uint256)
```

_Internal conversion function (from shares to assets) with support for rounding direction.
To mock non 1:1 share price_

## MockRevenueShareVault

### initialize

```solidity
function initialize(address asset_, string name_, string symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_) public
```

vault initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | underneath asset, which should match the asset of the yield source vault |
| name_ | string | ERC20 name of the vault shares token |
| symbol_ | string | ERC20 symbol of the vault shares token |
| yieldSourceVault_ | address | vault address of yield source |
| cinchPerformanceFeePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |

### nonInitialize

```solidity
function nonInitialize(address asset_, string name_, string symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_) external
```

_for testing the onlyInitializing modifier of __RevenueShareVault_init_

### nonInitializeUnchained

```solidity
function nonInitializeUnchained(address asset_, string name_, string symbol_, address yieldSourceVault_, uint256 cinchPerformanceFeePercentage_) external
```

_for testing the onlyInitializing modifier of __RevenueShareVault_init_unchained_

### getYieldSourceVaultTotalShares

```solidity
function getYieldSourceVaultTotalShares() external view virtual returns (uint256)
```

_to be used for calculating the revenue share ratio_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | yieldSourceTotalShares total yield source shares supply |

### shareBalanceAtYieldSourceOf

```solidity
function shareBalanceAtYieldSourceOf(address account) public view virtual returns (uint256)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | target account address |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares yield source share balance of this vault |

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address asset_, uint256 amount_) internal virtual returns (uint256)
```

_Deposit assets to yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The address of the ERC20 asset contract |
| amount_ | uint256 | The amount of assets to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares received |

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256 shares) internal virtual returns (uint256)
```

_Redeem assets with vault shares from yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to burn and redeem assets |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

## MockRevenueShareVaultAttacker

### reInitGeneralRevenueShareLogic

```solidity
function reInitGeneralRevenueShareLogic() external
```

### reInitGeneralRevenueShareLogicUnChained

```solidity
function reInitGeneralRevenueShareLogicUnChained() external
```

### reInitGeneralYieldSourceAdapter

```solidity
function reInitGeneralYieldSourceAdapter() external
```

### reInitGeneralYieldSourceAdapterUnChained

```solidity
function reInitGeneralYieldSourceAdapterUnChained() external
```

### reInitDepositPausable

```solidity
function reInitDepositPausable() external
```

### reInitDepositPausableUnChained

```solidity
function reInitDepositPausableUnChained() external
```

### forceFakeDepositState

```solidity
function forceFakeDepositState(uint256 shares, address receiver, address referral) external
```

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address, uint256 assetAmount_) internal returns (uint256)
```

_For testing reentrancy guard_

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256 shares) internal returns (uint256)
```

_For testing reentrancy guard_

## MockRevenueShareVaultDHedgeAttacker

### forceFakeDepositState

```solidity
function forceFakeDepositState(uint256 shares, address receiver, address referral) external
```

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256 shares, uint256 expectedAmountOut) internal returns (uint256)
```

_For testing reentrancy guard_

## DepositPausableUpgradeable

_Contract module which allows children to implement an emergency stop
mechanism that can be triggered by an authorized account.

This module is used through inheritance. It will make available the
modifiers `whenNotPaused` and `whenPaused`, which can be applied to
the functions of your contract. Note that they will not be pausable by
simply including this module, only once the modifiers are put in place._

### DepositPaused

```solidity
event DepositPaused(address account)
```

_Emitted when the pause is triggered by `account`._

### DepositUnpaused

```solidity
event DepositUnpaused(address account)
```

_Emitted when the pause is lifted by `account`._

### whenDepositNotPaused

```solidity
modifier whenDepositNotPaused()
```

_Modifier to make a function callable only when the contract is not paused.

Requirements:

- The contract must not be paused._

### whenDepositPaused

```solidity
modifier whenDepositPaused()
```

_Modifier to make a function callable only when the contract is paused.

Requirements:

- The contract must be paused._

### __DepositPausable_init

```solidity
function __DepositPausable_init() internal
```

_Initializes the contract in unpaused state._

### __DepositPausable_init_unchained

```solidity
function __DepositPausable_init_unchained() internal
```

### pauseDeposit

```solidity
function pauseDeposit() external virtual
```

_Triggers stopped state.

Requirements:

- The contract must not be paused._

### unpauseDeposit

```solidity
function unpauseDeposit() external virtual
```

_Returns to normal state.

Requirements:

- The contract must be paused._

### depositPaused

```solidity
function depositPaused() public view virtual returns (bool)
```

_Returns true if the contract is paused, and false otherwise._

### _requireDepositNotPaused

```solidity
function _requireDepositNotPaused() internal view virtual
```

_Throws if the contract is paused._

### _requireDepositPaused

```solidity
function _requireDepositPaused() internal view virtual
```

_Throws if the contract is not paused._

