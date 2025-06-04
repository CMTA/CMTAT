# ERC20Burn Module

This document defines the ERC20Burn Module for the CMTA Token specification.

[TOC]



## Rationale

> This function allows the issuer to destroy specific tokens that are recorded on a distributed ledger address. This function is meant to be used if the issuer cancels tokenized shares (e.g. if it reduces its share capital, if it has decided to have the shares in a different form (e.g. “simple” uncertificated securities within the meaning of Article 973c CO or paper certificates), or to comply with a court order requiring the cancellation of tokens pursuant to Article 973h CO).

## Schema

![ERC20BurnUML](../../../schema/uml/ERC20BurnUML.png)

### Inheritance

![surya_inheritance_BurnModule.sol](../../../schema/surya_inheritance/surya_inheritance_ERC20BurnModule.sol.png)



### Graph

![surya_graph_BurnModule.sol](../../../schema/surya_graph/surya_graph_ERC20BurnModule.sol.png)

## API for Ethereum

This section describes the Ethereum API of Burn Module.

### Functions

#### `burn(address,uint256,bytes)`

##### Definition

```solidity
function burn(address account,uint256 value,bytes calldata data) 
public virtual override(IERC7551Burn) 
onlyRole(BURNER_ROLE)
```

##### Description

Destroys a `value` amount of tokens from `account`, by transferring it to address(0).

##### Requirements

Only authorized users (*BURNER_ROLE*) are allowed to call this function.

##### Events

###### `Burn(address, address, uint,string)`

```solidity
event Burn(address indexed burner, address indexed account, uint256 value, bytes data)
```

Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `data`

#### `burn(address,uint256,bytes)`

##### Definition

```solidity
function burn(address account,uint256 value) 
public virtual override(IERC3643Burn) 
onlyRole(BURNER_ROLE)
```

##### Description

Destroys a `value` amount of tokens from `account`, by transferring it to address(0).

##### Requirements

Only authorized users (*BURNER_ROLE*) are allowed to call this function.

##### Events

###### `Burn(address,address, uint,bytes)`

```solidity
event Burn(address indexed burner, address indexed account, uint256 value, bytes data)
```

Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `data`

#### `batchBurn(address[],uint256[],bytes)  `

##### Definition

```solidity
function batchBurn(address[] calldata accounts,uint256[] calldata values,bytes memory data) 
public virtual onlyRole(BURNER_ROLE)
```

##### Description

For each account in `accounts`, destroys a `value` amount of tokens from `account`, by transferring it to address(0).

The burn `data`is the same for all `accounts` which tokens are burnt.

##### Requirements

- `accounts` and `values` must have the same length

- The caller must have the `BURNER_ROLE`.

##### Event

###### BatchBurn

```solidity
event BatchBurn(address indexed burner,address[] accounts,uint256[] values,bytes data);
```

#### `batchBurn(address[],uint256[],bytes)  `

##### Definition

```solidity
function batchBurn(address[] calldata accounts, uint256[] calldata values) 
public virtual override (IERC3643Burn) onlyRole(BURNER_ROLE)
```

##### Description

For each account in `accounts`, destroys a `value` amount of tokens from `account`, by transferring it to address(0).

The burn `data`is the same for all `accounts` which tokens are burnt.

##### Requirements

- `accounts` and `values` must have the same length

- The caller must have the `BURNER_ROLE`.

##### Event

```solidity
event BatchBurn(address indexed burner,address[] accounts,uint256[] values,bytes data);
```

