# Solidity API

## Errors

### InvalidTransfer

```solidity
error InvalidTransfer(address from, address to, uint256 amount)
```

### AddressZeroNotAllowed

```solidity
error AddressZeroNotAllowed()
```

### SameValue

```solidity
error SameValue()
```

## CMTAT_BASE

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address admin, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, string information_, uint256 flag_) public
```

@notice
initialize the proxy contract
The calls to this function will revert if the contract was deployed without a proxy

### __CMTAT_init

```solidity
function __CMTAT_init(address admin, string nameIrrevocable, string symbolIrrevocable, uint8 decimalsIrrevocable, string tokenId_, string terms_, string information_, uint256 flag_) internal
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

## AuthorizationModule

### BURNER_ROLE

```solidity
bytes32 BURNER_ROLE
```

### MINTER_ROLE

```solidity
bytes32 MINTER_ROLE
```

### PAUSER_ROLE

```solidity
bytes32 PAUSER_ROLE
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

## BaseModule

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

