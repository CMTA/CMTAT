# Solidity API

## CMTAT_PROXY

### constructor

```solidity
constructor(address forwarderIrrevocable) public
```

## CMTAT_STANDALONE

### constructor

```solidity
constructor(address forwarderIrrevocable, address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) public
```

## IDebtGlobal

### DebtBase

```solidity
struct DebtBase {
  uint256 interestRate;
  uint256 parValue;
  string guarantor;
  string bondHolder;
  string maturityDate;
  string interestScheduleFormat;
  string interestPaymentDate;
  string dayCountConvention;
  string businessDayConvention;
  string publicHolidaysCalendar;
  string issuanceDate;
  string couponFrequency;
}
```

### CreditEvents

```solidity
struct CreditEvents {
  bool flagDefault;
  bool flagRedeemed;
  string rating;
}
```

## IEIP1404

### detectTransferRestriction

```solidity
function detectTransferRestriction(address _from, address _to, uint256 _amount) external view returns (uint8)
```

_See ERC/EIP-1404_

### messageForTransferRestriction

```solidity
function messageForTransferRestriction(uint8 _restrictionCode) external view returns (string)
```

_See ERC/EIP-1404_

## IEIP1404Wrapper

### REJECTED_CODE_BASE

```solidity
enum REJECTED_CODE_BASE {
  TRANSFER_OK,
  TRANSFER_REJECTED_PAUSED,
  TRANSFER_REJECTED_FROM_FROZEN,
  TRANSFER_REJECTED_TO_FROZEN
}
```

### validateTransfer

```solidity
function validateTransfer(address _from, address _to, uint256 _amount) external view returns (bool isValid)
```

_Returns true if the transfer is valid, and false otherwise._

## MinimalForwarderMock

### initialize

```solidity
function initialize() public
```

## CodeList

### AMOUNT_TOO_HIGH

```solidity
uint8 AMOUNT_TOO_HIGH
```

### TEXT_AMOUNT_TOO_HIGH

```solidity
string TEXT_AMOUNT_TOO_HIGH
```

### TEXT_CODE_NOT_FOUND

```solidity
string TEXT_CODE_NOT_FOUND
```

## RuleEngineMock

### _rules

```solidity
contract IRule[] _rules
```

### constructor

```solidity
constructor() public
```

### setRules

```solidity
function setRules(contract IRule[] rules_) external
```

_define the rules, the precedent rules will be overwritten_

### rulesCount

```solidity
function rulesCount() external view returns (uint256)
```

_return the number of rules_

### rule

```solidity
function rule(uint256 ruleId) external view returns (contract IRule)
```

_return the rule at the index specified by ruleId_

### rules

```solidity
function rules() external view returns (contract IRule[])
```

_return all the rules_

### detectTransferRestriction

```solidity
function detectTransferRestriction(address _from, address _to, uint256 _amount) public view returns (uint8)
```

_See ERC/EIP-1404_

### validateTransfer

```solidity
function validateTransfer(address _from, address _to, uint256 _amount) public view returns (bool)
```

_Returns true if the transfer is valid, and false otherwise._

### messageForTransferRestriction

```solidity
function messageForTransferRestriction(uint8 _restrictionCode) public view returns (string)
```

@dev
    For all the rules, each restriction code has to be unique.

## RuleMock

### validateTransfer

```solidity
function validateTransfer(address _from, address _to, uint256 _amount) public pure returns (bool isValid)
```

_Returns true if the transfer is valid, and false otherwise._

### detectTransferRestriction

```solidity
function detectTransferRestriction(address, address, uint256 _amount) public pure returns (uint8)
```

_20 the limit of the maximum amount_

### canReturnTransferRestrictionCode

```solidity
function canReturnTransferRestrictionCode(uint8 _restrictionCode) public pure returns (bool)
```

_Returns true if the restriction code exists, and false otherwise._

### messageForTransferRestriction

```solidity
function messageForTransferRestriction(uint8 _restrictionCode) external pure returns (string)
```

_See ERC/EIP-1404_

## IRule

### canReturnTransferRestrictionCode

```solidity
function canReturnTransferRestrictionCode(uint8 _restrictionCode) external view returns (bool)
```

_Returns true if the restriction code exists, and false otherwise._

## IRuleEngine

### setRules

```solidity
function setRules(contract IRule[] rules_) external
```

_define the rules, the precedent rules will be overwritten_

### rulesCount

```solidity
function rulesCount() external view returns (uint256)
```

_return the number of rules_

### rule

```solidity
function rule(uint256 ruleId) external view returns (contract IRule)
```

_return the rule at the index specified by ruleId_

### rules

```solidity
function rules() external view returns (contract IRule[])
```

_return all the rules_

## CMTAT_BASE

### initialize

```solidity
function initialize(address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) public
```

initialize the proxy contract
    The calls to this function will revert if the contract was deployed without a proxy

### __CMTAT_init

```solidity
function __CMTAT_init(address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) internal
```

_calls the different initialize functions from the different modules_

### __CMTAT_init_unchained

```solidity
function __CMTAT_init_unchained() internal
```

### decimals

```solidity
function decimals() public view virtual returns (uint8)
```

Returns the number of decimals used to get its user representation.

### transferFrom

```solidity
function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool)
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal view
```

_Hook that is called before any transfer of tokens. This includes
minting and burning.

Calling conditions:

- when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
will be transferred to `to`.
- when `from` is zero, `amount` tokens will be minted for `to`.
- when `to` is zero, `amount` of ``from``'s tokens will be burned.
- `from` and `to` are never both zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

### _msgSender

```solidity
function _msgSender() internal view returns (address sender)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

### _msgData

```solidity
function _msgData() internal view returns (bytes)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

## EnforcementModuleInternal

_Enforcement module.

Allows the issuer to freeze transfers from a given address_

### Freeze

```solidity
event Freeze(address enforcer, address owner, string reasonIndexed, string reason)
```

Emitted when an address is frozen.

### Unfreeze

```solidity
event Unfreeze(address enforcer, address owner, string reasonIndexed, string reason)
```

Emitted when an address is unfrozen.

### __Enforcement_init

```solidity
function __Enforcement_init() internal
```

_Initializes the contract_

### __Enforcement_init_unchained

```solidity
function __Enforcement_init_unchained() internal
```

### frozen

```solidity
function frozen(address account) public view virtual returns (bool)
```

_Returns true if the account is frozen, and false otherwise._

### _freeze

```solidity
function _freeze(address account, string reason) internal virtual returns (bool)
```

_Freezes an address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the account to freeze |
| reason | string | indicate why the account was frozen. |

### _unfreeze

```solidity
function _unfreeze(address account, string reason) internal virtual returns (bool)
```

_Unfreezes an address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the account to unfreeze |
| reason | string | indicate why the account was unfrozen. |

## SnapshotModuleInternal

_Snapshot module.

Useful to take a snapshot of token holder balance and total supply at a specific time
Inspired by Openzeppelin - ERC20Snapshot but use the time as Id instead of a counter.
Contrary to OpenZeppelin, the function _getCurrentSnapshotId is not available 
   because overriding this function can break the contract._

### SnapshotSchedule

```solidity
event SnapshotSchedule(uint256 oldTime, uint256 newTime)
```

Emitted when the snapshot with the specified oldTime was scheduled or rescheduled at the specified newTime.

### SnapshotUnschedule

```solidity
event SnapshotUnschedule(uint256 time)
```

Emitted when the scheduled snapshot with the specified time was cancelled.

### Snapshots

```solidity
struct Snapshots {
  uint256[] ids;
  uint256[] values;
}
```

### __Snapshot_init

```solidity
function __Snapshot_init(string name_, string symbol_) internal
```

_Initializes the contract_

### __Snapshot_init_unchained

```solidity
function __Snapshot_init_unchained() internal
```

### _scheduleSnapshot

```solidity
function _scheduleSnapshot(uint256 time) internal
```

_schedule a snapshot at the specified time
    You can only add a snapshot after the last previous_

### _scheduleSnapshotNotOptimized

```solidity
function _scheduleSnapshotNotOptimized(uint256 time) internal
```

_schedule a snapshot at the specified time_

### _rescheduleSnapshot

```solidity
function _rescheduleSnapshot(uint256 oldTime, uint256 newTime) internal
```

_reschedule a scheduled snapshot at the specified newTime_

### _unscheduleLastSnapshot

```solidity
function _unscheduleLastSnapshot(uint256 time) internal
```

_unschedule the last scheduled snapshot_

### _unscheduleSnapshotNotOptimized

```solidity
function _unscheduleSnapshotNotOptimized(uint256 time) internal
```

_unschedule (remove) a scheduled snapshot in three steps:
    - search the snapshot in the list
    - If found, move all next snapshots one position to the left
    - Reduce the array size by deleting the last snapshot_

### getNextSnapshots

```solidity
function getNextSnapshots() public view returns (uint256[])
```

_Get the next scheduled snapshots_

### getAllSnapshots

```solidity
function getAllSnapshots() public view returns (uint256[])
```

_Get all snapshots_

### snapshotBalanceOf

```solidity
function snapshotBalanceOf(uint256 time, address owner) public view returns (uint256)
```

Return the number of tokens owned by the given owner at the time when the snapshot with the given time was created.
    @return value stored in the snapshot, or the actual balance if no snapshot

### snapshotTotalSupply

```solidity
function snapshotTotalSupply(uint256 time) public view returns (uint256)
```

_See {OpenZeppelin - ERC20Snapshot}
    Retrieves the total supply at the specified time.
    @return value stored in the snapshot, or the actual totalSupply if no snapshot_

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual
```

_Update balance and/or total supply snapshots before the values are modified. This is implemented
    in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations._

### _setCurrentSnapshot

```solidity
function _setCurrentSnapshot() internal
```

@dev
    Set the currentSnapshotTime by retrieving the most recent snapshot
    if a snapshot exists, clear all past scheduled snapshot

## ValidationModuleInternal

_Validation module.

Useful for to restrict and validate transfers_

### RuleEngine

```solidity
event RuleEngine(contract IEIP1404Wrapper newRuleEngine)
```

_Emitted when a rule engine is set._

### ruleEngine

```solidity
contract IEIP1404Wrapper ruleEngine
```

### __Validation_init

```solidity
function __Validation_init(contract IEIP1404Wrapper ruleEngine_) internal
```

_Initializes the contract with rule engine._

### __Validation_init_unchained

```solidity
function __Validation_init_unchained(contract IEIP1404Wrapper ruleEngine_) internal
```

### _validateTransfer

```solidity
function _validateTransfer(address from, address to, uint256 amount) internal view returns (bool)
```

_before making a call to this function, you have to check if a ruleEngine is set._

### _messageForTransferRestriction

```solidity
function _messageForTransferRestriction(uint8 restrictionCode) internal view returns (string)
```

_before making a call to this function, you have to check if a ruleEngine is set._

### _detectTransferRestriction

```solidity
function _detectTransferRestriction(address from, address to, uint256 amount) internal view returns (uint8)
```

_before making a call to this function, you have to check if a ruleEngine is set._

## AuthorizationModule

### BURNER_ROLE

```solidity
bytes32 BURNER_ROLE
```

### ENFORCER_ROLE

```solidity
bytes32 ENFORCER_ROLE
```

### MINTER_ROLE

```solidity
bytes32 MINTER_ROLE
```

### PAUSER_ROLE

```solidity
bytes32 PAUSER_ROLE
```

### SNAPSHOOTER_ROLE

```solidity
bytes32 SNAPSHOOTER_ROLE
```

### DEBT_ROLE

```solidity
bytes32 DEBT_ROLE
```

### DEBT_CREDIT_EVENT_ROLE

```solidity
bytes32 DEBT_CREDIT_EVENT_ROLE
```

### __AuthorizationModule_init

```solidity
function __AuthorizationModule_init(address admin) internal
```

### __AuthorizationModule_init_unchained

```solidity
function __AuthorizationModule_init_unchained(address admin) internal
```

_Grants the different roles to the
account that deploys the contract._

### hasRole

```solidity
function hasRole(bytes32 role, address account) public view virtual returns (bool)
```

_Returns `true` if `account` has been granted `role`._

## OnlyDelegateCallModule

_When a contract is deployed with a proxy, insure that some functions (e.g. delegatecall and selfdestruct) can only be triggered through proxies 
and not on the implementation contract itself._

### onlyDelegateCall

```solidity
modifier onlyDelegateCall(bool deployedWithProxy)
```

## BaseModule

### deployedWithProxy

```solidity
bool deployedWithProxy
```

### Term

```solidity
event Term(string newTermIndexed, string newTerm)
```

### TokenId

```solidity
event TokenId(string newTokenIdIndexed, string newTokenId)
```

### Information

```solidity
event Information(string newInformationIndexed, string newInformation)
```

### Flag

```solidity
event Flag(uint256 newFlag)
```

### tokenId

```solidity
string tokenId
```

### terms

```solidity
string terms
```

### information

```solidity
string information
```

### flag

```solidity
uint256 flag
```

### __Base_init

```solidity
function __Base_init(string tokenId_, string terms_, string information_, uint256 flag_, address admin) internal
```

_Sets the values for {name} and {symbol}.

All two of these values are immutable: they can only be set once during
construction._

### __Base_init_unchained

```solidity
function __Base_init_unchained(string tokenId_, string terms_, string information_, uint256 flag_) internal
```

### setTokenId

```solidity
function setTokenId(string tokenId_) public
```

### setTerms

```solidity
function setTerms(string terms_) public
```

### setInformation

```solidity
function setInformation(string information_) public
```

### setFlag

```solidity
function setFlag(uint256 flag_) public
```

### kill

```solidity
function kill() public
```

## BurnModule

### Burn

```solidity
event Burn(address owner, uint256 amount, string reason)
```

### __BurnModule_init

```solidity
function __BurnModule_init(string name_, string symbol_, address admin) internal
```

### __BurnModule_init_unchained

```solidity
function __BurnModule_init_unchained() internal
```

### forceBurn

```solidity
function forceBurn(address account, uint256 amount, string reason) public
```

_Destroys `amount` tokens from `account`

See {ERC20-_burn}_

## ERC20BaseModule

### Spend

```solidity
event Spend(address owner, address spender, uint256 amount)
```

### __ERC20Module_init

```solidity
function __ERC20Module_init(string name_, string symbol_, uint8 decimals_) internal
```

_Sets the values for {name} and {symbol}.

All two of these values are immutable: they can only be set once during
construction._

### __ERC20Module_init_unchained

```solidity
function __ERC20Module_init_unchained(uint8 decimals_) internal
```

### decimals

```solidity
function decimals() public view virtual returns (uint8)
```

Returns the number of decimals used to get its user representation.
@dev
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5,05` (`505 / 10 ** 2`).

Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the value {ERC20} uses, unless this function is
overridden;

NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}.

### transferFrom

```solidity
function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool)
```

_See {IERC20-transferFrom}.

Emits an {Approval} event indicating the updated allowance. This is not
required by the EIP. See the note at the beginning of {ERC20}.

Requirements:

- `sender` and `recipient` cannot be the zero address.
- `sender` must have a balance of at least `amount`.
- the caller must have allowance for ``sender``'s tokens of at least
`amount`._

### approve

```solidity
function approve(address spender, uint256 amount, uint256 currentAllowance) public virtual returns (bool)
```

_See {IERC20-approve}.

Requirements:

- `spender` cannot be the zero address._

## EnforcementModule

_Enforcement module.

Allows the issuer to freeze transfers from a given address_

### TEXT_TRANSFER_REJECTED_FROM_FROZEN

```solidity
string TEXT_TRANSFER_REJECTED_FROM_FROZEN
```

### TEXT_TRANSFER_REJECTED_TO_FROZEN

```solidity
string TEXT_TRANSFER_REJECTED_TO_FROZEN
```

### __EnforcementModule_init

```solidity
function __EnforcementModule_init(address admin) internal
```

### __EnforcementModule_init_unchained

```solidity
function __EnforcementModule_init_unchained() internal
```

### freeze

```solidity
function freeze(address account, string reason) public returns (bool)
```

Freezes an address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the account to freeze |
| reason | string | indicate why the account was frozen. |

### unfreeze

```solidity
function unfreeze(address account, string reason) public returns (bool)
```

Unfreezes an address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the account to unfreeze |
| reason | string | indicate why the account was unfrozen. |

## MintModule

### Mint

```solidity
event Mint(address beneficiary, uint256 amount)
```

### __MintModule_init

```solidity
function __MintModule_init(string name_, string symbol_, address admin) internal
```

### __MintModule_init_unchained

```solidity
function __MintModule_init_unchained() internal
```

### mint

```solidity
function mint(address to, uint256 amount) public
```

_Creates `amount` new tokens for `to`.

See {ERC20-_mint}.

Requirements:

- the caller must have the `MINTER_ROLE`._

## PauseModule

_ERC20 token with pausable token transfers, minting and burning.

Useful for scenarios such as preventing trades until the end of an evaluation
period, or having an emergency switch for freezing all token transfers in the
event of a large bug._

### TEXT_TRANSFER_REJECTED_PAUSED

```solidity
string TEXT_TRANSFER_REJECTED_PAUSED
```

### __PauseModule_init

```solidity
function __PauseModule_init(address admin) internal
```

### __PauseModule_init_unchained

```solidity
function __PauseModule_init_unchained() internal
```

### pause

```solidity
function pause() public
```

_Pauses all token transfers.

See {ERC20Pausable} and {Pausable-_pause}.

Requirements:

- the caller must have the `PAUSER_ROLE`._

### unpause

```solidity
function unpause() public
```

_Unpauses all token transfers.

See {ERC20Pausable} and {Pausable-_unpause}.

Requirements:

- the caller must have the `PAUSER_ROLE`._

## CreditEventsModule

### creditEvents

```solidity
struct IDebtGlobal.CreditEvents creditEvents
```

### FlagDefault

```solidity
event FlagDefault(bool newFlagDefault)
```

### FlagRedeemed

```solidity
event FlagRedeemed(bool newFlagRedeemed)
```

### Rating

```solidity
event Rating(string newRatingIndexed, string newRating)
```

### __CreditEvents_init

```solidity
function __CreditEvents_init(address admin) internal
```

### __CreditEvents_init_unchained

```solidity
function __CreditEvents_init_unchained() internal
```

### setCreditEvents

```solidity
function setCreditEvents(bool flagDefault_, bool flagRedeemed_, string rating_) public
```

### setFlagDefault

```solidity
function setFlagDefault(bool flagDefault_) public
```

### setFlagRedeemed

```solidity
function setFlagRedeemed(bool flagRedeemed_) public
```

### setRating

```solidity
function setRating(string rating_) public
```

## DebtBaseModule

### debt

```solidity
struct IDebtGlobal.DebtBase debt
```

### InterestRate

```solidity
event InterestRate(uint256 newInterestRate)
```

### ParValue

```solidity
event ParValue(uint256 newParValue)
```

### Guarantor

```solidity
event Guarantor(string newGuarantorIndexed, string newGuarantor)
```

### BondHolder

```solidity
event BondHolder(string newBondHolderIndexed, string newBondHolder)
```

### MaturityDate

```solidity
event MaturityDate(string newMaturityDateIndexed, string newMaturityDate)
```

### InterestScheduleFormat

```solidity
event InterestScheduleFormat(string newInterestScheduleFormatIndexed, string newInterestScheduleFormat)
```

### InterestPaymentDate

```solidity
event InterestPaymentDate(string newInterestPaymentDateIndexed, string newInterestPaymentDate)
```

### DayCountConvention

```solidity
event DayCountConvention(string newDayCountConventionIndexed, string newDayCountConvention)
```

### BusinessDayConvention

```solidity
event BusinessDayConvention(string newBusinessDayConventionIndexed, string newBusinessDayConvention)
```

### PublicHolidaysCalendar

```solidity
event PublicHolidaysCalendar(string newPublicHolidaysCalendarIndexed, string newPublicHolidaysCalendar)
```

### IssuanceDate

```solidity
event IssuanceDate(string newIssuanceDateIndexed, string newIssuanceDate)
```

### CouponFrequency

```solidity
event CouponFrequency(string newCouponFrequencyIndexed, string newCouponFrequency)
```

### __DebtBaseModule_init

```solidity
function __DebtBaseModule_init(address admin) internal
```

### __DebtBaseModule_init_unchained

```solidity
function __DebtBaseModule_init_unchained() internal
```

### setDebt

```solidity
function setDebt(struct IDebtGlobal.DebtBase debt_) public
```

### setInterestRate

```solidity
function setInterestRate(uint256 interestRate_) public
```

### setParValue

```solidity
function setParValue(uint256 parValue_) public
```

### setGuarantor

```solidity
function setGuarantor(string guarantor_) public
```

### setBondHolder

```solidity
function setBondHolder(string bondHolder_) public
```

### setMaturityDate

```solidity
function setMaturityDate(string maturityDate_) public
```

### setInterestScheduleFormat

```solidity
function setInterestScheduleFormat(string interestScheduleFormat_) public
```

### setInterestPaymentDate

```solidity
function setInterestPaymentDate(string interestPaymentDate_) public
```

### setDayCountConvention

```solidity
function setDayCountConvention(string dayCountConvention_) public
```

### setBusinessDayConvention

```solidity
function setBusinessDayConvention(string businessDayConvention_) public
```

### setPublicHolidaysCalendar

```solidity
function setPublicHolidaysCalendar(string publicHolidaysCalendar_) public
```

### setIssuanceDate

```solidity
function setIssuanceDate(string issuanceDate_) public
```

### setCouponFrequency

```solidity
function setCouponFrequency(string couponFrequency_) public
```

## MetaTxModule

_Meta transaction (gasless) module.

Useful for to provide UX where the user does not pay gas for token exchange
To follow OpenZeppelin, this contract does not implement the functions init & init_unchained.
()_

### constructor

```solidity
constructor(address trustedForwarder) internal
```

### _msgSender

```solidity
function _msgSender() internal view virtual returns (address sender)
```

### _msgData

```solidity
function _msgData() internal view virtual returns (bytes)
```

## SnapshotModule

_Snapshot module.

Useful to take a snapshot of token holder balance and total supply at a specific time_

### __SnasphotModule_init

```solidity
function __SnasphotModule_init(string name_, string symbol_, address admin) internal
```

### __SnasphotModule_init_unchained

```solidity
function __SnasphotModule_init_unchained() internal
```

### scheduleSnapshot

```solidity
function scheduleSnapshot(uint256 time) public
```

### scheduleSnapshotNotOptimized

```solidity
function scheduleSnapshotNotOptimized(uint256 time) public
```

### rescheduleSnapshot

```solidity
function rescheduleSnapshot(uint256 oldTime, uint256 newTime) public
```

### unscheduleLastSnapshot

```solidity
function unscheduleLastSnapshot(uint256 time) public
```

### unscheduleSnapshotNotOptimized

```solidity
function unscheduleSnapshotNotOptimized(uint256 time) public
```

## ValidationModule

_Validation module.

Useful for to restrict and validate transfers_

### TEXT_TRANSFER_OK

```solidity
string TEXT_TRANSFER_OK
```

### TEXT_UNKNOWN_CODE

```solidity
string TEXT_UNKNOWN_CODE
```

### __ValidationModule_init

```solidity
function __ValidationModule_init(contract IEIP1404Wrapper ruleEngine_, address admin) internal
```

### __ValidationModule_init_unchained

```solidity
function __ValidationModule_init_unchained() internal
```

### setRuleEngine

```solidity
function setRuleEngine(contract IEIP1404Wrapper ruleEngine_) external
```

### detectTransferRestriction

```solidity
function detectTransferRestriction(address from, address to, uint256 amount) public view returns (uint8 code)
```

_ERC1404 check if _value token can be transferred from _from to _to_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | address The address which you want to send tokens from |
| to | address | address The address which you want to transfer to |
| amount | uint256 | uint256 the amount of tokens to be transferred |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| code | uint8 | of the rejection reason |

### messageForTransferRestriction

```solidity
function messageForTransferRestriction(uint8 restrictionCode) external view returns (string message)
```

_ERC1404 returns the human readable explaination corresponding to the error code returned by detectTransferRestriction_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| restrictionCode | uint8 | The error code returned by detectTransferRestriction |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | The human readable explaination corresponding to the error code returned by detectTransferRestriction |

### validateTransfer

```solidity
function validateTransfer(address from, address to, uint256 amount) public view returns (bool)
```

## CMTATSnapshotProxyTest

### constructor

```solidity
constructor(address forwarderIrrevocable) public
```

## CMTATSnapshotStandaloneTest

### constructor

```solidity
constructor(address forwarderIrrevocable, address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId, string terms, contract IEIP1404Wrapper ruleEngine, string information, uint256 flag) public
```

## CMTAT_BASE_SnapshotTest

### initialize

```solidity
function initialize(address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId, string terms, contract IEIP1404Wrapper ruleEngine, string information, uint256 flag) public
```

initialize the proxy contract
    The calls to this function will revert if the contract was deployed without a proxy

### __CMTAT_init

```solidity
function __CMTAT_init(address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId, string terms, contract IEIP1404Wrapper ruleEngine, string information, uint256 flag) internal
```

_calls the different initialize functions from the different modules
    @param admin the address has to be different from 0, check made in AuthorizationModule_

### __CMTAT_init_unchained

```solidity
function __CMTAT_init_unchained() internal
```

### decimals

```solidity
function decimals() public view virtual returns (uint8)
```

Returns the number of decimals used to get its user representation.

### transferFrom

```solidity
function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool)
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal
```

### _msgSender

```solidity
function _msgSender() internal view returns (address sender)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

### _msgData

```solidity
function _msgData() internal view returns (bytes)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

## BaseModuleTest

_This version has removed the check of access control on the kill function
The only remaining protection is the call to the modifier onlyDelegateCall_

### kill

```solidity
function kill() public
```

### deployedWithProxy

```solidity
bool deployedWithProxy
```

### TermSet

```solidity
event TermSet(string newTerm)
```

### TokenIdSet

```solidity
event TokenIdSet(string newTokenId)
```

### InformationSet

```solidity
event InformationSet(string newInformation)
```

### FlagSet

```solidity
event FlagSet(uint256 newFlag)
```

### tokenId

```solidity
string tokenId
```

### terms

```solidity
string terms
```

### information

```solidity
string information
```

### flag

```solidity
uint256 flag
```

### __Base_init

```solidity
function __Base_init(string tokenId_, string terms_, string information_, uint256 flag_, address admin) internal
```

_Sets the values for {name} and {symbol}.

All two of these values are immutable: they can only be set once during
construction._

### __Base_init_unchained

```solidity
function __Base_init_unchained(string tokenId_, string terms_, string information_, uint256 flag_) internal
```

### setTokenId

```solidity
function setTokenId(string tokenId_) public
```

### setTerms

```solidity
function setTerms(string terms_) public
```

### setInformation

```solidity
function setInformation(string information_) public
```

### setFlag

```solidity
function setFlag(uint256 flag_) public
```

## CMTAT_KILL_TEST

_This version inherits from BaseModuleTest instead of BaseModule_

### constructor

```solidity
constructor(address forwarderIrrevocable) public
```

### initialize

```solidity
function initialize(address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId, string terms, contract IEIP1404Wrapper ruleEngine, string information, uint256 flag) public
```

initialize the proxy contract
    The calls to this function will revert if the contract was deployed without a proxy

### __CMTAT_init

```solidity
function __CMTAT_init(address admin, string nameIrrevocable, string symbolIrrevocable, string tokenId, string terms, contract IEIP1404Wrapper ruleEngine, string information, uint256 flag) internal
```

_calls the different initialize functions from the different modules_

### __CMTAT_init_unchained

```solidity
function __CMTAT_init_unchained() internal
```

### decimals

```solidity
function decimals() public view virtual returns (uint8)
```

Returns the number of decimals used to get its user representation.

### transferFrom

```solidity
function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool)
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal view
```

_Hook that is called before any transfer of tokens. This includes
minting and burning.

Calling conditions:

- when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
will be transferred to `to`.
- when `from` is zero, `amount` tokens will be minted for `to`.
- when `to` is zero, `amount` of ``from``'s tokens will be burned.
- `from` and `to` are never both zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

### _msgSender

```solidity
function _msgSender() internal view returns (address sender)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

### _msgData

```solidity
function _msgData() internal view returns (bytes)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

