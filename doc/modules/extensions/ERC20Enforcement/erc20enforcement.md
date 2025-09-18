# ERC20 Enforcement Module

This document defines ERC20 Enforcement Module for the CMTA Token specification.

[TOC]

## Rationale

> Enforce a transfer: Transfer an amount of tokens without requiring the consent of the holder. This function which can be implemented in situations when it needs to be clear a transfer is enforced to comply with a transfer order, for example from a judicial authority
>
> Partial freeze: Partially freeze the balance of a token holder 

## Schema

![EnforcementUML](../../../schema/uml/ERC20EnforcementUML.png)

### Inheritance

![surya_inheritance_ERC20EnforcementModule.sol](../../../schema/surya_inheritance/surya_inheritance_ERC20EnforcementModule.sol.png)



### Graph



![surya_graph_ERC20EnforcementModule.sol](../../../schema/surya_graph/surya_graph_ERC20EnforcementModule.sol.png)

## API for Ethereum



### Interface: `IERC3643ERC20Enforcement`

This module defines an interface for managing **token freezing** and **forced transfers**. It's designed for compliance use cases, such as in regulated environments or permissioned token systems.

#### Structs

*No structs are defined in this interface.*

------

#### Events

*For event definitions, refer to the `IERC7551ERC20Enforcement` interface.*

------

#### Functions

##### `getFrozenTokens(address) -> (uint256)`

```solidity
function getFrozenTokens(address account) external view returns (uint256 frozenBalance_)
```

```solidity
function getFrozenTokens(address account) 
public override(IERC7551ERC20Enforcement, IERC3643ERC20Enforcement) 
view virtual 
returns (uint256)
```

Returns the number of tokens that are currently frozen (i.e., non-transferable) for a given account.

**Parameters**

| Name      | Type    | Description                                          |
| --------- | ------- | ---------------------------------------------------- |
| `account` | address | Address of the wallet to check frozen token balance. |



**Returns**

| Name             | Type    | Description              |
| ---------------- | ------- | ------------------------ |
| `frozenBalance_` | uint256 | Amount of frozen tokens. |



------

##### `freezePartialTokens(address,uint256)`

```solidity
function freezePartialTokens(address account, uint256 value) external
```

```solidity
function freezePartialTokens(address account, uint256 value) 
public virtual override(IERC3643ERC20Enforcement) 
onlyERC20Enforcer
```

Freezes a specific amount of tokens for a given address, making them non-transferable.

**Parameters**

| Name      | Type    | Description                          |
| --------- | ------- | ------------------------------------ |
| `account` | address | Address whose tokens will be frozen. |
| `value`   | uint256 | Amount of tokens to freeze.          |



**Emits:** `TokensFrozen`

**Requirements:**

- Only authorized users (*ERC20ENFORCER_ROLE*) are allowed to call this function.

------

##### `unfreezePartialTokens(account, uint256)`

```solidity
function unfreezePartialTokens(address account, uint256 value) external
```

```solidity
function unfreezePartialTokens(address account, uint256 value) 
public virtual override(IERC3643ERC20Enforcement) 
onlyERC20Enforcer
```

Unfreezes a specific amount of tokens for a given address, making them transferable again.

**Parameters**

| Name      | Type    | Description                            |
| --------- | ------- | -------------------------------------- |
| `account` | address | Address whose tokens will be unfrozen. |
| `value`   | uint256 | Amount of tokens to unfreeze.          |



**Emits:** `TokensUnfrozen`

**Requirements:**

- Only authorized users (*ERC20ENFORCER_ROLE*) are allowed to call this function.

------

##### `forcedTransfer(address, address,uint256)`

```solidity
function forcedTransfer(address from, address to, uint256 value) external returns (bool)
```

```solidity
function forcedTransfer(address from, address to, uint256 value) 
public virtual override(IERC3643ERC20Enforcement) 
onlyForcedTransferManager 
returns (bool)
```

Triggers a forced token transfer from one account to another, even if the source account has insufficient free (unfrozen) tokens. 

If needed, frozen tokens are automatically unfrozen to fulfill the transfer.

**Parameters**

| Name    | Type    | Description                                             |
| ------- | ------- | ------------------------------------------------------- |
| `from`  | address | Address from which tokens will be forcibly transferred. |
| `to`    | address | Address that will receive the tokens.                   |
| `value` | uint256 | Amount of tokens to transfer.                           |



**Returns**

| Name       | Type | Description                     |
| ---------- | ---- | ------------------------------- |
| `success_` | bool | True if the transfer succeeded. |



**Emits:**

- `TokensUnfrozen` (if frozen tokens are used)
- `Transfer` (always on success)

**Requirements:**

- Only authorized users (*DEFAULT_ADMIN_ROLE*) are allowed to call this function.

### Interface:`IERC7551ERC20Enforcement`

> Defines token enforcement rules, including freezing/unfreezing tokens, tracking active balances, and allowing forced transfers.

------

#### Structs

*None*

------

#### Events

*See related events in `IERC7551ERC20EnforcementEvent`:*

- `TokensFrozen(address account, uint256 amount, bytes data)`
- `TokensUnfrozen(address account, uint256 amount, bytes data)`
- `Transfer(address from, address to, uint256 value)`

------

#### Functions

------

##### `getActiveBalanceOf(address)`

```solidity
function getActiveBalanceOf(address account) external view returns (uint256)
```

```solidity
function getActiveBalanceOf(address account) 
public view override(IERC7551ERC20Enforcement) 
returns (uint256 activeBalance_)
```

Returns the number of tokens that are currently **active (i.e., not frozen)** for the specified account. These tokens are available for standard ERC-20 transfers.

**Parameters:**

| Name      | Type    | Description                                  |
| --------- | ------- | -------------------------------------------- |
| `account` | address | The address to check the active balance for. |



**Returns:**

| Name             | Type    | Description                                      |
| ---------------- | ------- | ------------------------------------------------ |
| `activeBalance_` | uint256 | Amount of tokens that can be transferred freely. |



------

##### `getFrozenTokens(address)`

```solidity
function getFrozenTokens(address account) public view returns (uint256)
```

Returns the number of tokens that are **currently frozen** and cannot be transferred via ERC-20 `transfer` or `transferFrom`.

**Parameters:**

| Name      | Type    | Description                             |
| --------- | ------- | --------------------------------------- |
| `account` | address | The address to check frozen tokens for. |



**Returns:**

| Name             | Type    | Description                                      |
| ---------------- | ------- | ------------------------------------------------ |
| `frozenBalance_` | uint256 | Number of tokens locked from standard transfers. |



------

##### `freezePartialTokens(address,uint256,bytes)`

```solidity
function freezePartialTokens(address account, uint256 amount, bytes memory data) external
```

```solidity
function freezePartialTokens(address account, uint256 value, bytes calldata data) 
public virtual override(IERC7551ERC20Enforcement) 
onlyERC20Enforcer
```

Freezes a portion of the tokens held by a specific address.

**Parameters:**

| Name      | Type    | Description                                 |
| --------- | ------- | ------------------------------------------- |
| `account` | address | The address whose tokens are being frozen.  |
| `amount`  | uint256 | The number of tokens to freeze.             |
| `data`    | bytes   | Additional metadata or reason for freezing. |

**Requirements:**

- Only authorized users (*ERC20ENFORCER_ROLE*) are allowed to call this function.

------

##### `unfreezePartialTokens(address,uint256,bytes)`

```solidity
function unfreezePartialTokens(address account, uint256 amount, bytes memory data) external
```

```solidity
function unfreezePartialTokens(address account, uint256 value, bytes calldata data) 
public virtual override(IERC7551ERC20Enforcement) 
onlyERC20Enforcer
```

Unfreezes a portion of the tokens previously frozen for a specific account.

**Parameters:**

| Name      | Type    | Description                                   |
| --------- | ------- | --------------------------------------------- |
| `account` | address | The address whose tokens are being unfrozen.  |
| `amount`  | uint256 | The number of tokens to unfreeze.             |
| `data`    | bytes   | Additional metadata or reason for unfreezing. |

**Requirements:**

- Only authorized users (*ERC20ENFORCER_ROLE*) are allowed to call this function.

------

##### `forcedTransfer(address,address,uint256,bytes)`

```solidity
function forcedTransfer(address account, address to, uint256 value, bytes calldata data) external returns (bool)
```

```solidity
function forcedTransfer(address from, address to, uint256 value, bytes calldata data) 
public virtual override(IERC7551ERC20Enforcement)  
onlyForcedTransferManager 
returns (bool) 
```

Performs a transfer of tokens from one account to another without requiring approval or allowance from the sender.

If the sender does not have enough unfrozen tokens, frozen tokens may be unfrozen automatically to fulfill the transfer. This emits a `TokensUnfrozen` event if needed.

**Parameters:**

| Name      | Type    | Description                                |
| --------- | ------- | ------------------------------------------ |
| `account` | address | The address to debit tokens from.          |
| `to`      | address | The recipient of the tokens.               |
| `value`   | uint256 | Number of tokens to transfer.              |
| `data`    | bytes   | Optional metadata for auditing or logging. |



**Returns:**

| Name       | Type | Description                         |
| ---------- | ---- | ----------------------------------- |
| `success_` | bool | Returns true if transfer succeeded. |

**Requirements:**

- Only authorized users (*DEFAULT_ADMIN_ROLE*) are allowed to call this function.
