# ERc20CrossChain

This document defines the ERC20CrossChain module for the CMTA Token specification.

[TOC]

## Schema

![ERC20CrossChain](../../schema/uml/ERC20CrossChainUML.png)

### Inheritance

![surya_inheritance_ERC20CrossChain.sol](../../schema/surya_inheritance/surya_inheritance_3_ERC20CrossChain.sol.png)



### Graph

![surya_graph_CoreModule.sol](../../schema/surya_graph/surya_graph_3_ERC20CrossChain.sol.png)

## API for Ethereum

This section describes the Ethereum API of this module.



### `IERC7802`

Defines the interface for crosschain ERC-20 token transfers.
 Extends: `IERC165`

#### Events

------

##### `CrosschainMint(address,uint256,address)`

```solidity
event CrosschainMint(address indexed to, uint256 value, address indexed sender);
```

Emitted when tokens are minted due to a crosschain transfer.

| Parameter | Type    | Description                                         |
| --------- | ------- | --------------------------------------------------- |
| `to`      | address | Recipient of the minted tokens.                     |
| `value`   | uint256 | Amount of tokens minted.                            |
| `sender`  | address | The address that finalized the crosschain transfer. |



------

##### `CrosschainBurn(address,uint256,address)`

```
event CrosschainBurn(address indexed from, uint256 value, address indexed sender);
```

Emitted when tokens are burned in preparation for a crosschain transfer.

| Parameter | Type    | Description                                         |
| --------- | ------- | --------------------------------------------------- |
| `from`    | address | Address whose tokens were burned.                   |
| `value`   | uint256 | Amount of tokens burned.                            |
| `sender`  | address | The address that initiated the crosschain transfer. |

#### Functions

##### `crosschainMint(address,uint256)`

```solidity
function crosschainMint(address to, uint256 value) external;
```

```solidity
function crosschainMint(address to, uint256 value) 
public virtual override(IERC7802)
onlyRole(CROSS_CHAIN_ROLE) whenNotPaused
```

Mints tokens as part of a crosschain transfer.

| Parameter | Type    | Description                           |
| --------- | ------- | ------------------------------------- |
| `to`      | address | Address that will receive the tokens. |
| `value`   | uint256 | Amount of tokens to mint.             |

**Returns:** None

**Requirement**

- The contract must not be paused 
  - error: `EnforcedPause()`
- Only authorized users (`CROSS_CHAIN_ROLE`) are allowed to call this function.

**Emits:**

- `CrosschainMint` event
- ERC-20`Transfer` event

------

##### `crosschainBurn(address,uint256)`

```solidity
function crosschainBurn(address from, uint256 value) external;
```

```solidity
function crosschainBurn(address from, uint256 value) 
public virtual override(IERC7802)
onlyRole(CROSS_CHAIN_ROLE) whenNotPaused
```

Burns tokens in preparation for a crosschain transfer.

| Parameter | Type    | Description                               |
| --------- | ------- | ----------------------------------------- |
| `from`    | address | Address from which tokens will be burned. |
| `value`   | uint256 | Amount of tokens to burn.                 |



**Returns:** None

**Requirement**

- The contract must not be paused 
  - error: `EnforcedPause()`
- Only authorized users (`CROSS_CHAIN_ROLE`) are allowed to call this function.

 **Emits:**

- `CrosschainBurn` event
- ERC-20`Transfer` event

------

### IBurnFromERC20

##### burnFrom(address,uint256)

```solidity
function burnFrom(address account, uint256 value)
public virtual override(IBurnFromERC20) 
onlyRole(BURNER_FROM_ROLE) whenNotPaused
```

Burns tokens from an account by using the caller’s allowance.

| Parameter | Type    | Description                      |
| --------- | ------- | -------------------------------- |
| `account` | address | The address to burn tokens from. |
| `value`   | uint256 | Number of tokens to burn.        |



**Returns:** None

**Requirements:**

- Caller must have sufficient allowance to burn tokens from `account`.
- The contract must not be paused 
  - error: `EnforcedPause()`
- Only authorized users (`BURNER_FROM_ROLE`) are allowed to call this function.

**Emits:**

- A `BurnFrom` event.
- A `Spend` event
- A ERC-20`Transfer` event

------

##### burn(uint256)

Burns tokens from the caller’s own balance.

| Parameter | Type    | Description               |
| --------- | ------- | ------------------------- |
| `value`   | uint256 | Number of tokens to burn. |

**Returns:** None

**Requirements:**

- The contract must not be paused 
  - error: `EnforcedPause()`
- Only authorized users (`BURNER_FROM_ROLE`) are allowed to call this function.

**Emits:**

- A ERC-20`Transfer` event
- A `BurnFrom`event
