# Solidity API

## GeneralRevenueShareLogic

_sub-contract of Cinch Vault that handles revenue share distribution_

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

### TotalSharesByReferralUpdated

```solidity
event TotalSharesByReferralUpdated(address referral, uint256 shares_)
```

_Emitted upon setTotalSharesByReferral_

### TotalSharesInReferralUpdated

```solidity
event TotalSharesInReferralUpdated(uint256 shares_)
```

_Emitted upon setTotalSharesInReferral_

### _referralSet

```solidity
struct EnumerableSetUpgradeable.AddressSet _referralSet
```

_Address set of all referrals_

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

### _userSetByReferral

```solidity
mapping(address => struct EnumerableSetUpgradeable.AddressSet) _userSetByReferral
```

_Address set of all users by referral_

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

### getRevenueShareReferralSet

```solidity
function getRevenueShareReferralSet() external view returns (address[] referrals)
```

Getter for the cinchPxPayeeSet

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| referrals | address[] | The array of referrals |

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

### setTotalSharesByReferral

```solidity
function setTotalSharesByReferral(address referral, uint256 shares_) external virtual
```

_In case the integration does not have full control over the yield source withdrawal process, contract owner will be able to fix any discrepancy according to the off-chain tracking.
onlyOwner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| referral | address | The address of the referral |
| shares_ | uint256 | The amount of shares decreased |

### setTotalSharesInReferral

```solidity
function setTotalSharesInReferral(uint256 shares_) external virtual
```

_In case the integration does not have full control over the yield source withdrawal process, contract owner will be able to fix any discrepancy according to the off-chain tracking.
onlyOwner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares_ | uint256 | The amount of shares decreased |

### depositToRevenueShare

```solidity
function depositToRevenueShare(address assetsFrom_, address asset_, uint256 amount_) external virtual
```

Deposit asset as revenue share into this vault

_The amount will be splitted among referrals according to their shares ratio
whenNotPaused nonReentrant_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assetsFrom_ | address | The address of the asset owner that the deposit will be taken from |
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

### setCinchPerformanceFeePercentage

```solidity
function setCinchPerformanceFeePercentage(uint256 feePercentage_) external virtual
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |

## GeneralYieldSourceAdapter

_sub-contract of Revenue Share Vault, serving as the Yield Source Adapter template_

### YieldSourceVaultUpdated

```solidity
event YieldSourceVaultUpdated(address yieldSourceVault_)
```

_Emitted when the yieldSourceVault address is updated._

### yieldSourceVault

```solidity
address yieldSourceVault
```

_Yield source vault address_

### yieldSourceSwapper

```solidity
address yieldSourceSwapper
```

_Yield source swapper address_

### __GeneralYieldSourceAdapter_init

```solidity
function __GeneralYieldSourceAdapter_init(address yieldSourceVault_, address yieldSourceSwapper_) internal
```

GeneralYieldSourceAdapter initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| yieldSourceVault_ | address | vault address of yield source |
| yieldSourceSwapper_ | address | swapper address of yield source |

### __GeneralYieldSourceAdapter_init_unchained

```solidity
function __GeneralYieldSourceAdapter_init_unchained(address yieldSourceVault_, address yieldSourceSwapper_) internal
```

### setYieldSourceVault

```solidity
function setYieldSourceVault(address yieldSourceVault_) external
```

setter of yieldSourceVault

_onlyOwner
emit YieldSourceVaultUpdated_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| yieldSourceVault_ | address | address of yieldSourceVault to be updated to |

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address asset_, uint256 assets_) internal virtual returns (uint256)
```

_Deposit assets to yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The addres of the ERC20 asset contract |
| assets_ | uint256 | The amount of assets to deposit |

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

### sharePriceOfYieldSource

```solidity
function sharePriceOfYieldSource() public view virtual returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | price share price of yield source vault |

### _convertAssetsToYieldSourceShares

```solidity
function _convertAssetsToYieldSourceShares(uint256 assets, enum MathUpgradeable.Rounding rounding) internal view virtual returns (uint256)
```

Returns the amount of shares that the yield source vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | amount of assets to be converted to shares |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares that would be converted from assets |

### _convertYieldSourceSharesToAssets

```solidity
function _convertYieldSourceSharesToAssets(uint256 shares, enum MathUpgradeable.Rounding rounding) internal view virtual returns (uint256)
```

Returns the amount of assets that the yield source vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to be converted to assets |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets that would be converted from shares |

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

### getYieldSourceVaultTotalShares

```solidity
function getYieldSourceVaultTotalShares() external view virtual returns (uint256)
```

_to be used for calculating the revenue share ratio_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | yieldSourceTotalShares total yield source shares supply |

### assetBalanceAtYieldSourceOf

```solidity
function assetBalanceAtYieldSourceOf(address account, address referral) public view virtual returns (uint256)
```

_abstruct function to be implemented by specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | target account address |
| referral | address | target referral address |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets that the user has deposited to the vault |

## RevenueShareVault

Contract allows deposits and Withdrawals to Yield source product

_Should be deployed per yield source pool/vault
ERC4626 based vault_

### DepositWithReferral

```solidity
event DepositWithReferral(address caller, address receiver, uint256 assets, uint256 shares, address referral)
```

_Emitted when user deposit with referral_

### RedeemWithReferral

```solidity
event RedeemWithReferral(address caller, address receiver, address sharesOwner, uint256 assets, uint256 shares, address referral)
```

_Emitted when user redeem with referral_

### totalAssetDepositProcessed

```solidity
uint256 totalAssetDepositProcessed
```

_Total asset deposit processed_

### initialize

```solidity
function initialize(address asset_, string name, string symbol, address yieldSourceVault_, address yieldSourceSwapper_, uint256 cinchPerformanceFeePercentage_) public
```

vault initializer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | underneath asset, which should match the asset of the yield source vault |
| name | string | ERC20 name of the vault shares token |
| symbol | string | ERC20 symbol of the vault shares token |
| yieldSourceVault_ | address | vault address of yield source |
| yieldSourceSwapper_ | address | swapper address of yield source |
| cinchPerformanceFeePercentage_ | uint256 | Cinch performance fee percentage with 2 decimals |

### deposit

```solidity
function deposit(uint256 assets, address receiver) public virtual returns (uint256)
```

Deposit assets to the vault

_See {IERC4626-deposit}
depositWithReferral(assets, receiver, receiver)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | amount of assets to deposit |
| receiver | address | address to receive the shares |

### depositWithReferral

```solidity
function depositWithReferral(uint256 assets, address receiver, address referral) public virtual returns (uint256)
```

Deposit assets to the vault with referral

_Transfer assets to this contract, then deposit into yield source vault, and mint shares to receiver
See {IERC4626-deposit}
whenNotPaused whenDepositNotPaused nonReentrant
emit Deposit_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | amount of assets to deposit |
| receiver | address | address to receive the shares |
| referral | address | address of the partner referral |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares received |

### mint

```solidity
function mint(uint256 shares, address receiver) public virtual returns (uint256)
```

Mint shares with assets
As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
In this case, the shares will be minted without requiring any assets to be deposited.

_See {IERC4626-mint}
depositWithReferral(assets, receiver, receiver)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to mint |
| receiver | address | address to receive the shares |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets consumed |

### redeem

```solidity
function redeem(uint256 shares, address receiver, address sharesOwner) public virtual returns (uint256)
```

Redeem assets with vault shares

_See {IERC4626-redeem}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to burn and redeem assets |
| receiver | address | address to receive the assets |
| sharesOwner | address | address of the owner of the shares to be consumed, require to be _msgSender() for better security |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

### redeemWithReferral

```solidity
function redeemWithReferral(uint256 shares, address receiver, address sharesOwner, address referral) public virtual returns (uint256)
```

Redeem assets with vault shares and referral

_See {IERC4626-redeem}
whenNotPaused
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
| [0] | uint256 | assets amount of assets received |

### withdraw

```solidity
function withdraw(uint256 assets, address receiver, address sharesOwner) public virtual returns (uint256)
```

Withdraw a specific amount of assets to be redeemed with vault shares

_See {IERC4626-withdraw}
redeem_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | target amount of assets to be withdrawn |
| receiver | address | address to receive the assets |
| sharesOwner | address | address of the owner of the shares to be consumed |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

### withdrawWithReferral

```solidity
function withdrawWithReferral(uint256 assets, address receiver, address sharesOwner, address referral) public virtual returns (uint256)
```

Withdraw a specific amount of assets to be redeemed with vault shares and referral

_See {IERC4626-withdraw}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | target amount of assets to be withdrawn |
| receiver | address | address to receive the assets |
| sharesOwner | address | address of the owner of the shares to be consumed |
| referral | address | address of the partner referral |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets received |

### totalAssets

```solidity
function totalAssets() public view virtual returns (uint256)
```

_See {IERC4626-totalAssets}_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets total amount of the underlying asset managed by this vault |

### maxDeposit

```solidity
function maxDeposit(address) public view virtual returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets maximum asset amounts that can be deposited |

### maxWithdraw

```solidity
function maxWithdraw(address _owner) public view virtual returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets maximum asset amounts that can be withdrawn |

### _convertToShares

```solidity
function _convertToShares(uint256 assets, enum MathUpgradeable.Rounding rounding) internal view virtual returns (uint256)
```

Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | amount of assets to be converted to shares |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares that would be converted from assets |

### _convertToAssets

```solidity
function _convertToAssets(uint256 shares, enum MathUpgradeable.Rounding rounding) internal view virtual returns (uint256)
```

Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to be converted to assets |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets that would be converted from shares |

### assetBalanceAtYieldSourceOf

```solidity
function assetBalanceAtYieldSourceOf(address account, address referral) public view virtual returns (uint256)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | target account address |
| referral | address | target referral address |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets that the user has deposited to the vault |

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

## RevenueShareVaultDHedge

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address asset_, uint256 assets_) internal returns (uint256)
```

_Deposit assets to yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The addres of the ERC20 asset contract |
| assets_ | uint256 | The amount of assets to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares received |

### _redeemFromYieldSourceVault

```solidity
function _redeemFromYieldSourceVault(uint256 shares) internal returns (uint256)
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

### sharePriceOfYieldSource

```solidity
function sharePriceOfYieldSource() public view returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | price share price of yield source vault |

### _convertAssetsToYieldSourceShares

```solidity
function _convertAssetsToYieldSourceShares(uint256 assets, enum MathUpgradeable.Rounding rounding) internal view returns (uint256)
```

Returns the amount of shares that the yield source vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | amount of assets to be converted to shares |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares that would be converted from assets |

### _convertYieldSourceSharesToAssets

```solidity
function _convertYieldSourceSharesToAssets(uint256 shares, enum MathUpgradeable.Rounding rounding) internal view returns (uint256)
```

Returns the amount of assets that the yield source vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to be converted to assets |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets that would be converted from shares |

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

### getYieldSourceVaultTotalShares

```solidity
function getYieldSourceVaultTotalShares() external view returns (uint256)
```

_to be used for calculating the revenue share ratio_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | yieldSourceTotalShares total yield source shares supply |

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

## RevenueShareVaultRibbonEarn

### _depositToYieldSourceVault

```solidity
function _depositToYieldSourceVault(address asset_, uint256 assets_) internal returns (uint256)
```

_Deposit assets to yield source vault
virtual, expected to be overridden with specific yield source vault_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| asset_ | address | The addres of the ERC20 asset contract |
| assets_ | uint256 | The amount of assets to deposit |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares received |

### redeemWithReferral

```solidity
function redeemWithReferral(uint256, address, address, address) public returns (uint256)
```

Redeem assets with vault shares and referral

_See {IERC4626-redeem}
For this integration, because of Ribbon Earn's multiple steps withdrawal (with time delay) mechanism, this contract will not be processing the yield source's withdrawal directly, but only for burning the intenal shares for tracking the revenue share.
when _msgSender() != sharesOwner, then the sharesOwner must have approved this contract to spend the shares (checked inside the _withdraw call)
shares amount of shares to burn and redeem assets
receiver address to receive the assets
sharesOwner address of the owner of the shares to be consumed, require to be _msgSender() for better security
referral address of the partner referral_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets_ amount of assets received |

### sharePriceOfYieldSource

```solidity
function sharePriceOfYieldSource() public view returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | price share price of yield source vault |

### _convertAssetsToYieldSourceShares

```solidity
function _convertAssetsToYieldSourceShares(uint256 assets, enum MathUpgradeable.Rounding rounding) internal view returns (uint256)
```

Returns the amount of shares that the yield source vault would exchange for the amount of assets provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assets | uint256 | amount of assets to be converted to shares |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | shares amount of shares that would be converted from assets |

### _convertYieldSourceSharesToAssets

```solidity
function _convertYieldSourceSharesToAssets(uint256 shares, enum MathUpgradeable.Rounding rounding) internal view returns (uint256)
```

Returns the amount of assets that the yield source vault would exchange for the amount of shares provided, in an ideal scenario where all the conditions are met

_See {@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol}_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares | uint256 | amount of shares to be converted to assets |
| rounding | enum MathUpgradeable.Rounding | rounding mode |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets amount of assets that would be converted from shares |

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

### getYieldSourceVaultTotalShares

```solidity
function getYieldSourceVaultTotalShares() external view returns (uint256)
```

_to be used for calculating the revenue share ratio_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | yieldSourceTotalShares total yield source shares supply |

### totalAssets

```solidity
function totalAssets() public view returns (uint256)
```

_See {IERC4626-totalAssets}_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | assets total amount of the underlying asset managed by this vault |

### totalShareBalanceAtYieldSourceInReferralSet

```solidity
function totalShareBalanceAtYieldSourceInReferralSet() external view returns (uint256 shares_)
```

_Since this vault does not have direct control over the Ribbon Earn vault's withdrawal, using this function to provide an accurate calculation of totalShareBalanceAtYieldSourceInReferralSet_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| shares_ | uint256 | total share balance at yield source in referral set |

### setTotalSharesInReferralAccordingToYieldSource

```solidity
function setTotalSharesInReferralAccordingToYieldSource() external
```

_Since this vault does not have direct control over the Ribbon Earn vault's withdrawal, using this function to provide an accurate calculation of totalSharesInReferral
onlyOwner_

## IYieldSourceContract

### deposit

```solidity
function deposit(uint256 assets, address receiver) external returns (uint256)
```

### redeem

```solidity
function redeem(uint256 shares, address receiver, address owner) external returns (uint256)
```

### sharePrice

```solidity
function sharePrice() external view returns (uint256)
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

### tokenPrice

```solidity
function tokenPrice() external view returns (uint256 price)
```

Get price of the asset adjusted for any unminted manager fees

_https://github.com/dhedge/V2-Public/blob/ba2f06d40a87e18a150f4055def5e7a2d596c719/contracts/PoolLogic.sol#L584
price is in unit of USD with 18 decimals_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

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

### sharePrice

```solidity
function sharePrice() public pure returns (uint256)
```

## MockProtocolDHedge

### constructor

```solidity
constructor(address asset_) public
```

### tokenPrice

```solidity
function tokenPrice() public pure returns (uint256)
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

### pricePerShare

```solidity
function pricePerShare() external pure returns (uint256)
```

The price of a unit of share denominated in the `asset`

### _convertToShares

```solidity
function _convertToShares(uint256 assets, enum Math.Rounding) internal pure returns (uint256)
```

_Internal conversion function (from assets to shares) with support for rounding direction._

### _convertToAssets

```solidity
function _convertToAssets(uint256 shares_, enum Math.Rounding) internal pure returns (uint256)
```

_Internal conversion function (from shares to assets) with support for rounding direction._

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

### __DepositPausable_init

```solidity
function __DepositPausable_init() internal
```

_Initializes the contract in unpaused state._

### __DepositPausable_init_unchained

```solidity
function __DepositPausable_init_unchained() internal
```

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

