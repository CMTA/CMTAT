# Allowlist Module

This document defines the Allowlist module

[TOC]

## Schema

![DebtUML](../../../schema/uml/AllowlistUML.png)

### Inheritance

![surya_inheritance_AllowlistModule.sol](../../../schema/surya_inheritance/surya_inheritance_AllowlistModule.sol.png)





### Graph

![surya_graph_AllowlistModule.sol](../../../schema/surya_graph/surya_graph_AllowlistModule.sol.png)

## API for Ethereum

This section describes the Ethereum API of Allowlist Module.

See also [IAllowlistModule](../../../../contracts/interfaces/modules/IAllowlistModule.sol))

### Events

------

#### `AddressAddedToAllowlist` 

```solidity
event AddressAddedToAllowlist(address indexed account, bool indexed status, address indexed enforcer, bytes data)
```

*Emitted when an address is added to or removed from the allowlist.*

#### Parameters

| Name     | Type    | Description                                  |
| -------- | ------- | -------------------------------------------- |
| account  | address | Address that was added or removed.           |
| status   | bool    | `true` if added, `false` if removed.         |
| enforcer | address | The caller who performed the action.         |
| data     | bytes   | Optional data associated with the operation. |



------

#### `AllowlistEnableStatus`

```solidity
event AllowlistEnableStatus(address indexed operator, bool status)
```

*Emitted when the allowlist is enabled or disabled.*

#### Parameters

| Name     | Type    | Description                             |
| -------- | ------- | --------------------------------------- |
| operator | address | Address that perform the current action |
| status   | bool    | `true` if enabled, `false` if disabled. |

### Functions

#### `isAllowlisted(address)`

```solidity
function isAllowlisted(address account) external view returns (bool)
```

```solidity
function isAllowlisted(address account) public view virtual returns (bool)
```

*Checks if an address is on the allowlist.*

#### Parameters

| Name    | Type    | Description           |
| ------- | ------- | --------------------- |
| account | address | The address to check. |



#### Returns

| Type | Description                           |
| ---- | ------------------------------------- |
| bool | `true` if the address is allowlisted. |



------

#### `setAddressAllowlist(address,bool)`

```solidity
function setAddressAllowlist(address account, bool status) external
```

```solidity
function setAddressAllowlist(address account, bool status) 
public virtual  
onlyRole(ALLOWLIST_ROLE)
```

*Adds or removes an address from the allowlist.*

#### Parameters

| Name    | Type    | Description                              |
| ------- | ------- | ---------------------------------------- |
| account | address | The address whose status will be changed |
| status  | bool    | `true` to add, `false` to remove.        |

**Requirements:**

- Only authorized users (*ALLOWLIST_ROLE*) are allowed to call this function.

------

#### `setAddressAllowlist(address,bool,bytes)`

```solidity
function setAddressAllowlist(address account, bool status, bytes calldata data) external
```

```solidity
function setAddressAllowlist(address account, bool status, bytes calldata data) public virtual 
onlyRole(ALLOWLIST_ROLE)
```

*Adds or removes an address from the allowlist, with optional data.*

#### Parameters

| Name    | Type    | Description                                  |
| ------- | ------- | -------------------------------------------- |
| account | address | The address whose status will be changed     |
| status  | bool    | `true` to add, `false` to remove.            |
| data    | bytes   | Optional data (e.g., reason, metadata, etc). |

**Requirements:**

- Only authorized users (*ALLOWLIST_ROLE*) are allowed to call this function.

------

#### `batchSetAddressAllowlist(address[],bool[])`

```solidity
function batchSetAddressAllowlist(address[] calldata accounts, bool[] calldata status) external
```

```solidity
function batchSetAddressAllowlist(address[] calldata accounts, bool[] calldata status) 
public virtual 
onlyRole(ALLOWLIST_ROLE)
```

*Adds or removes multiple addresses from the allowlist in one call.*

#### Parameters

| Name     | Type      | Description                                    |
| -------- | --------- | ---------------------------------------------- |
| accounts | address[] | List of addresses to update their statuses.    |
| status   | bool[]    | Matching list of statuses (`true` or `false`). |

**Requirements:**

- Only authorized users (*ALLOWLIST_ROLE*) are allowed to call this function.

------

#### `enableAllowlist(bool)`

```solidity
function enableAllowlist(bool status) external
```

```solidity
function enableAllowlist(bool status) 
public virtual 
onlyRole(ALLOWLIST_ROLE)
```

*Enables or disables the allowlist system.*

#### Parameters

| Name   | Type | Description                           |
| ------ | ---- | ------------------------------------- |
| status | bool | `true` to enable, `false` to disable. |

**Requirements:**

- Only authorized users (*ALLOWLIST_ROLE*) are allowed to call this function.

------

#### `isAllowlistEnabled()`

```solidity
function isAllowlistEnabled() external view returns (bool)
```

```solidity
function isAllowlistEnabled() 
public view virtual 
returns (bool)
```

*Checks whether the allowlist is currently enabled.*

#### Returns

| Type | Description                     |
| ---- | ------------------------------- |
| bool | `true` if allowlist is enabled. |


