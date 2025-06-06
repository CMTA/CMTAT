# ERC20Mint Module

This document defines ERC20Mint Module for the CMTA Token specification.

[TOC]



## Rationale

>  Traditional securities could be issued in different ways.  Bonds are usually issued all at once.  Normal shares could be issued several times, when the issuer wants to raise more capital.  ETF shares are continuously issued on demand.  The Mint Module covers scenarios for CMTA Token specification when the issuer needs to create new tokens in response to securities issuances.

## Schema

![ERC20MintUML](../../../schema/uml/ERC20MintUML.png)

### Inheritance

![surya_inheritance_MintModule.sol](../../../schema/surya_inheritance/surya_inheritance_ERC20MintModule.sol.png)



### Graph

![surya_graph_MintModule.sol](../../../schema/surya_graph/surya_graph_ERC20MintModule.sol.png)



## API for Ethereum

This section describes the Ethereum API of Issue Module.

### Function

#### `mint(address,uint256)`

##### Definition

```solidity
function mint(address account, uint256 value) 
public onlyRole(MINTER_ROLE)
```

##### Description

 Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)


##### Requirements

- Only authorized users (`MINTER_ROLE`) are allowed to call this function.
-  `account` cannot be the zero address (check made by _mint).

##### Events

###### Mint(address, address, uint256, bytes)


```solidity
event Mint(address indexed minter, address indexed account, uint256 value, bytes data)
```

Emitted when the specified  `value` amount of new tokens are created and
allocated to the specified `account`.

#### `mint(address,uint256,bytes)`

##### Definition

```solidity
function mint(address account, uint256 value, bytes calldata data) 
public virtual override(IERC7551Mint) 
onlyRole(MINTER_ROLE)
```

##### Description

 Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)


##### Requirements

- Only authorized users (`MINTER_ROLE`) are allowed to call this function.
- `account` cannot be the zero address (check made by _mint).

##### Events

###### Mint(address,uint256, bytes)


```solidity
event Mint(address indexed account, uint256 value, bytes data);
```

Emitted when the specified  `value` amount of new tokens are created and
allocated to the specified `account`.

#### `mintBatch(address[],uint256[]) `

##### Definition

```solidity
function mintBatch(address[] calldata accounts,uint256[] calldata values) 
public onlyRole(MINTER_ROLE)
```

##### Description

For each address in `accounts`, create the corresponding amount of tokens given by `amounts` and allocate them to the given address`to`.

##### Requirements

Only authorized users (`MINTER_ROLE`) are allowed to call this function

`accounts` and `values` must have the same length

`accounts` cannot contain a zero address (check made by _mint).

##### Events

```
 event BatchMint(address indexed minter,address[] accounts,uint256[] values)
```

#### `transferBatch(address[],uint256[])  `

##### Definition

```solidity
 function transferBatch(address[] calldata tos,uint256[] calldata values) 
 public 
 returns (bool) 
```

##### Description

For each address in `tos`, transfer the given `value` amount of tokens from the sender to the given address `to`.

##### Requirements

- `tos` and `values` must have the same length.

- The sender has to own the sum of tokens in `values`.
