# Solidity API

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

## Errors

### CMTAT_InvalidTransfer

```solidity
error CMTAT_InvalidTransfer(address from, address to, uint256 amount)
```

### CMTAT_SnapshotModule_SnapshotScheduledInThePast

```solidity
error CMTAT_SnapshotModule_SnapshotScheduledInThePast(uint256 time, uint256 timestamp)
```

### CMTAT_SnapshotModule_SnapshotTimestampBeforeLastSnapshot

```solidity
error CMTAT_SnapshotModule_SnapshotTimestampBeforeLastSnapshot(uint256 time, uint256 lastSnapshotTimestamp)
```

### CMTAT_SnapshotModule_SnapshotTimestampAfterNextSnapshot

```solidity
error CMTAT_SnapshotModule_SnapshotTimestampAfterNextSnapshot(uint256 time, uint256 nextSnapshotTimestamp)
```

### CMTAT_SnapshotModule_SnapshotTimestampBeforePreviousSnapshot

```solidity
error CMTAT_SnapshotModule_SnapshotTimestampBeforePreviousSnapshot(uint256 time, uint256 previousSnapshotTimestamp)
```

### CMTAT_SnapshotModule_SnapshotAlreadyExists

```solidity
error CMTAT_SnapshotModule_SnapshotAlreadyExists()
```

### CMTAT_SnapshotModule_SnapshotAlreadyDone

```solidity
error CMTAT_SnapshotModule_SnapshotAlreadyDone()
```

### CMTAT_SnapshotModule_NoSnapshotScheduled

```solidity
error CMTAT_SnapshotModule_NoSnapshotScheduled()
```

### CMTAT_SnapshotModule_SnapshotNotFound

```solidity
error CMTAT_SnapshotModule_SnapshotNotFound()
```

### CMTAT_ERC20BaseModule_WrongAllowance

```solidity
error CMTAT_ERC20BaseModule_WrongAllowance(address spender, uint256 currentAllowance, uint256 allowanceProvided)
```

### CMTAT_BurnModule_EmptyAccounts

```solidity
error CMTAT_BurnModule_EmptyAccounts()
```

### CMTAT_BurnModule_AccountsValueslengthMismatch

```solidity
error CMTAT_BurnModule_AccountsValueslengthMismatch()
```

### CMTAT_MintModule_EmptyAccounts

```solidity
error CMTAT_MintModule_EmptyAccounts()
```

### CMTAT_MintModule_AccountsValueslengthMismatch

```solidity
error CMTAT_MintModule_AccountsValueslengthMismatch()
```

### CMTAT_ERC20BaseModule_EmptyTos

```solidity
error CMTAT_ERC20BaseModule_EmptyTos()
```

### CMTAT_ERC20BaseModule_TosValueslengthMismatch

```solidity
error CMTAT_ERC20BaseModule_TosValueslengthMismatch()
```

### CMTAT_DebtModule_SameValue

```solidity
error CMTAT_DebtModule_SameValue()
```

### CMTAT_BaseModule_SameValue

```solidity
error CMTAT_BaseModule_SameValue()
```

### CMTAT_ValidationModule_SameValue

```solidity
error CMTAT_ValidationModule_SameValue()
```

### CMTAT_AuthorizationModule_AddressZeroNotAllowed

```solidity
error CMTAT_AuthorizationModule_AddressZeroNotAllowed()
```

### CMTAT_PauseModule_ContractIsDeactivated

```solidity
error CMTAT_PauseModule_ContractIsDeactivated()
```

## ERC20SnapshotModuleInternal

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

_See {OpenZeppelin - ERC20Snapshot}
    Snapshotted values have arrays of ids (time) and the value corresponding to that id.
    ids is expected to be sorted in ascending order, and to contain no repeated elements 
    because we use findUpperBound in the function _valueAt_

```solidity
struct Snapshots {
  uint256[] ids;
  uint256[] values;
}
```

### __ERC20Snapshot_init

```solidity
function __ERC20Snapshot_init(string name_, string symbol_) internal
```

_Initializes the contract_

### __ERC20Snapshot_init_unchained

```solidity
function __ERC20Snapshot_init_unchained() internal
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

### _update

```solidity
function _update(address from, address to, uint256 amount) internal virtual
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

### DEBT_CREDIT_EVENT_ROLE

```solidity
bytes32 DEBT_CREDIT_EVENT_ROLE
```

### DEBT_ROLE

```solidity
bytes32 DEBT_ROLE
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

### __AuthorizationModule_init

```solidity
function __AuthorizationModule_init(address admin, uint48 initialDelay) internal
```

### __AuthorizationModule_init_unchained

```solidity
function __AuthorizationModule_init_unchained() internal view
```

@dev

- The grant to the admin role is done by AccessControlDefaultAdminRules
- The control of the zero address is done by AccessControlDefaultAdminRules

### hasRole

```solidity
function hasRole(bytes32 role, address account) public view virtual returns (bool)
```

### transferAdminshipDirectly

```solidity
function transferAdminshipDirectly(address newAdmin) public virtual
```

@notice
    Warning: this function should be called only in case of necessity (e.g private key leak)
    Its goal is to transfer the adminship of the contract to a new admin, whithout delay.
    The prefer way is to use the workflow of AccessControlDefaultAdminRulesUpgradeable

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
function __ValidationModule_init(contract IEIP1404Wrapper ruleEngine_, address admin, uint48 initialDelayToAcceptAdminRole) internal
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

## BaseModule

### VERSION

```solidity
string VERSION
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
function __Base_init(string tokenId_, string terms_, string information_, uint256 flag_, address admin, uint48 initialDelayToAcceptAdminRole) internal
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

## ERC20BaseModule

### Spend

```solidity
event Spend(address owner, address spender, uint256 value)
```

Emitted when the specified `spender` spends the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.

### __ERC20Module_init

```solidity
function __ERC20Module_init(string name_, string symbol_, uint8 decimals_) internal
```

_Sets the values for {name}, {symbol} and decimals.

These values are immutable: they can only be set once during
construction/initialization._

### __ERC20Module_init_unchained

```solidity
function __ERC20Module_init_unchained(uint8 decimals_) internal
```

### decimals

```solidity
function decimals() public view virtual returns (uint8)
```

Returns the number of decimals used to get its user representation.

_Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).

Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the default value returned by this function, unless
it's overridden.

NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}._

### transferBatch

```solidity
function transferBatch(address[] tos, uint256[] values) public returns (bool)
```

batch version of transfer

_See {OpenZeppelin ERC20-transfer & ERC1155-safeBatchTransferFrom}.

Requirements:
- `tos` and `values` must have the same length
- `tos`cannot contain a zero address (check made by transfer)
- the caller must have a balance cooresponding to the total values_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tos | address[] | can not be empty, must have the same length as values |
| values | uint256[] | can not be empty |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 value) public virtual returns (bool)
```

Transfers `value` amount of tokens from address `from` to address `to`
@custom:dev-cmtat
Emits a {Spend} event indicating the spended allowance.

_See {IERC20-transferFrom}.

Emits an {Approval} event indicating the updated allowance. This is not
required by the EIP. See the note at the beginning of {ERC20}.

NOTE: Does not update the allowance if the current allowance
is the maximum `uint256`.

Requirements:

- `from` and `to` cannot be the zero address.
- `from` must have a balance of at least `value`.
- the caller must have allowance for ``from``'s tokens of at least
`value`._

### approve

```solidity
function approve(address spender, uint256 value, uint256 currentAllowance) public virtual returns (bool)
```

Allows `spender` to withdraw from your account multiple times, up to the `value` amount

_see {OpenZeppelin ERC20 - approve}_

## ERC20BurnModule

### Burn

```solidity
event Burn(address owner, uint256 value, string reason)
```

Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `reason`

### __ERC20BurnModule_init

```solidity
function __ERC20BurnModule_init(string name_, string symbol_, address admin, uint48 initialDelayToAcceptAdminRole) internal
```

### __ERC20BurnModule_init_unchained

```solidity
function __ERC20BurnModule_init_unchained() internal
```

### forceBurn

```solidity
function forceBurn(address account, uint256 value, string reason) public
```

Destroys a `value` amount of tokens from `account`, by transferring it to address(0).
@dev
See {ERC20-_burn}
Emits a {Burn} event
Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
Requirements:
- the caller must have the `BURNER_ROLE`.

### forceBurnBatch

```solidity
function forceBurnBatch(address[] accounts, uint256[] values, string reason) public
```

batch version of {forceBurn}.
@dev
See {ERC20-_burn} and {OpenZeppelin ERC1155_burnBatch}.

For each burn action:
-Emits a {Burn} event
-Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
The burn `reason`is the same for all `accounts` which tokens are burnt.
Requirements:
- `accounts` and `values` must have the same length
- the caller must have the `BURNER_ROLE`.

## ERC20MintModule

### Mint

```solidity
event Mint(address account, uint256 value)
```

Emitted when the specified  `value` amount of new tokens are created and
allocated to the specified `account`.

### __ERC20MintModule_init

```solidity
function __ERC20MintModule_init(string name_, string symbol_, address admin, uint48 initialDelayToAcceptAdminRole) internal
```

### __ERC20MintModule_init_unchained

```solidity
function __ERC20MintModule_init_unchained() internal
```

### mint

```solidity
function mint(address account, uint256 value) public
```

Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)
@dev
See {OpenZeppelin ERC20-_mint}.
Emits a {Mint} event.
Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).

Requirements:
- `account` cannot be the zero address (check made by _mint).
- The caller must have the `MINTER_ROLE`.

### mintBatch

```solidity
function mintBatch(address[] accounts, uint256[] values) public
```

batch version of {mint}
@dev
See {OpenZeppelin ERC20-_mint} and {OpenZeppelin ERC1155_mintBatch}.

For each mint action:
- Emits a {Mint} event.
- Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).

Requirements:
- `accounts` and `values` must have the same length
- `accounts` cannot contain a zero address (check made by _mint).
- the caller must have the `MINTER_ROLE`.

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
function __EnforcementModule_init(address admin, uint48 initialDelayToAcceptAdminRole) internal
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

## PauseModule

_Put in pause or deactivate the contract
The issuer must be able to “pause” the smart contract, 
to prevent execution of transactions on the distributed ledger until the issuer puts an end to the pause. 

Useful for scenarios such as preventing trades until the end of an evaluation
period, or having an emergency switch for freezing all token transfers in the
event of a large bug._

### TEXT_TRANSFER_REJECTED_PAUSED

```solidity
string TEXT_TRANSFER_REJECTED_PAUSED
```

### Deactivated

```solidity
event Deactivated(address account)
```

### __PauseModule_init

```solidity
function __PauseModule_init(address admin, uint48 initialDelayToAcceptAdminRole) internal
```

### __PauseModule_init_unchained

```solidity
function __PauseModule_init_unchained() internal
```

### pause

```solidity
function pause() public
```

Pauses all token transfers.

_See {ERC20Pausable} and {Pausable-_pause}.

Requirements:

- the caller must have the `PAUSER_ROLE`._

### unpause

```solidity
function unpause() public
```

Unpauses all token transfers.

_See {ERC20Pausable} and {Pausable-_unpause}.

Requirements:

- the caller must have the `PAUSER_ROLE`._

### deactivateContract

```solidity
function deactivateContract() public
```

deactivate the contract
Warning: the operation is irreversible, be careful
@dev
Emits a {Deactivated} event indicating that the contract has been deactivated.
Requirements:

- the caller must have the `DEFAULT_ADMIN_ROLE`.

### deactivated

```solidity
function deactivated() public view returns (bool)
```

Returns true if the contract is deactivated, and false otherwise.

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
function __CreditEvents_init(address admin, uint48 initialDelayToAcceptAdminRole) internal
```

### __CreditEvents_init_unchained

```solidity
function __CreditEvents_init_unchained() internal
```

### setCreditEvents

```solidity
function setCreditEvents(bool flagDefault_, bool flagRedeemed_, string rating_) public
```

Set all attributes of creditEvents
The values of all attributes will be changed even if the new values are the same as the current ones

### setFlagDefault

```solidity
function setFlagDefault(bool flagDefault_) public
```

The call will be reverted if the new value of flagDefault is the same as the current one

### setFlagRedeemed

```solidity
function setFlagRedeemed(bool flagRedeemed_) public
```

The call will be reverted if the new value of flagRedeemed is the same as the current one

### setRating

```solidity
function setRating(string rating_) public
```

The rating will be changed even if the new value is the same as the current one

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
function __DebtBaseModule_init(address admin, uint48 initialDelayToAcceptAdminRole) internal
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

## ERC20SnapshotModule

_Snapshot module.

Useful to take a snapshot of token holder balance and total supply at a specific time_

### __ERC20SnasphotModule_init

```solidity
function __ERC20SnasphotModule_init(string name_, string symbol_, address admin, uint48 initialDelayToAcceptAdminRole) internal
```

### __ERC20SnasphotModule_init_unchained

```solidity
function __ERC20SnasphotModule_init_unchained() internal
```

### scheduleSnapshot

```solidity
function scheduleSnapshot(uint256 time) public
```

Schedule a snapshot at the given time specified as a number of seconds since epoch.
The time cannot be before the time of the latest scheduled, but not yet created snapshot.

### scheduleSnapshotNotOptimized

```solidity
function scheduleSnapshotNotOptimized(uint256 time) public
```

Schedule a snapshot at the given time specified as a number of seconds since epoch.
The time cannot be before the time of the latest scheduled, but not yet created snapshot.

### rescheduleSnapshot

```solidity
function rescheduleSnapshot(uint256 oldTime, uint256 newTime) public
```

@notice
Reschedule the scheduled snapshot, but not yet created snapshot with the given oldTime to be created at the given newTime specified as a number of seconds since epoch. 
The newTime cannot be before the time of the previous scheduled, but not yet created snapshot, or after the time fo the next scheduled snapshot.

### unscheduleLastSnapshot

```solidity
function unscheduleLastSnapshot(uint256 time) public
```

Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time. 
There should not be any other snapshots scheduled after this one.

### unscheduleSnapshotNotOptimized

```solidity
function unscheduleSnapshotNotOptimized(uint256 time) public
```

Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time.

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

_Override for `msg.sender`. Defaults to the original `msg.sender` whenever
a call is not performed by the trusted forwarder or the calldata length is less than
20 bytes (an address length)._

### _msgData

```solidity
function _msgData() internal view virtual returns (bytes)
```

_Override for `msg.data`. Defaults to the original `msg.data` whenever
a call is not performed by the trusted forwarder or the calldata length is less than
20 bytes (an address length)._

## CMTATSnapshotProxyTest

### constructor

```solidity
constructor(address forwarderIrrevocable) public
```

## CMTATSnapshotStandaloneTest

### constructor

```solidity
constructor(address forwarderIrrevocable, address admin, uint48 initialDelayToAcceptAdminRole, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) public
```

## CMTAT_BASE_SnapshotTest

### initialize

```solidity
function initialize(address admin, uint48 initialDelayToAcceptAdminRole, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) public
```

initialize the proxy contract
    The calls to this function will revert if the contract was deployed without a proxy

### __CMTAT_init

```solidity
function __CMTAT_init(address admin, uint48 initialDelayToAcceptAdminRole, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) internal
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

### _update

```solidity
function _update(address from, address to, uint256 amount) internal
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

## CMTAT_PROXY

### constructor

```solidity
constructor(address forwarderIrrevocable) public
```

## CMTAT_STANDALONE

### constructor

```solidity
constructor(address forwarderIrrevocable, address admin, uint48 initialDelay, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) public
```

## CMTAT_BASE

### initialize

```solidity
function initialize(address admin, uint48 initialDelayToAcceptAdminRole, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) public
```

@notice
initialize the proxy contract
The calls to this function will revert if the contract was deployed without a proxy

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| admin | address | address of the admin of contract (Access Control) |
| initialDelayToAcceptAdminRole | uint48 |  |
| nameIrrevocable | string | name of the token |
| symbolIrrevocable | string | name of the symbol |
| decimalsIrrevocable | uint8 | number of decimals of the token, must be 0 to be compliant with Swiss law as per CMTAT specifications (non-zero decimal number may be needed for other use cases) |
| tokenId_ | string | name of the tokenId |
| terms_ | string | terms associated with the token |
| ruleEngine_ | contract IEIP1404Wrapper | address of the ruleEngine to apply rules to transfers |
| information_ | string | additional information to describe the token |
| flag_ | uint256 | add information under the form of bit(0, 1) |

### __CMTAT_init

```solidity
function __CMTAT_init(address admin, uint48 initialDelayToAcceptAdminRole, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, contract IEIP1404Wrapper ruleEngine_, string information_, uint256 flag_) internal
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

### _update

```solidity
function _update(address from, address to, uint256 amount) internal
```

@dev
SnapshotModule:
- override SnapshotModuleInternal if you add the SnapshotModule
e.g. override(ERC20SnapshotModuleInternal, ERC20Upgradeable)
- remove the keyword view

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

## CMTAT_PROXY_TEST

### constructor

```solidity
constructor(address forwarderIrrevocable) public
```

## MinimalForwarderMock

### initialize

```solidity
function initialize(string name) public
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

