# Mint Module

This document defines Mint Module for the CMTA Token specification.

[TOC]



## Rationale

>  Traditional securities could be issued in different ways.  Bonds are usually issued all at once.  Normal shares could be issued several times, when the issuer wants to raise more capital.  ETF shares are continuously issued on demand.  The Mint Module covers scenarios for CMTA Token specification when the issuer needs to create new tokens in response to securities issuances.

## Schema

### Inheritance

![surya_inheritance_MintModule.sol](../../schema/surya_inheritance/surya_inheritance_MintModule.sol.png)

### UML

![MintModule](../../schema/sol2uml/mandatory/MintModule.svg)

### Graph

![surya_graph_MintModule.sol](../../schema/surya_graph/surya_graph_MintModule.sol.png)



## Sūrya's Description Report

### Files Description Table


| File Name                                  | SHA-1 Hash                               |
| ------------------------------------------ | ---------------------------------------- |
| ./modules/wrapper/mandatory/MintModule.sol | 3d6fa6f2890f85f4f426aee39ea2ee31203f2109 |


### Contracts Description Table


|    Contract    |            Type             |                 Bases                 |                |                  |
| :------------: | :-------------------------: | :-----------------------------------: | :------------: | :--------------: |
|       └        |      **Function Name**      |            **Visibility**             | **Mutability** |  **Modifiers**   |
|                |                             |                                       |                |                  |
| **MintModule** |       Implementation        | ERC20Upgradeable, AuthorizationModule |                |                  |
|       └        |      __MintModule_init      |              Internal 🔒               |       🛑        | onlyInitializing |
|       └        | __MintModule_init_unchained |              Internal 🔒               |       🛑        | onlyInitializing |
|       └        |            mint             |               Public ❗️                |       🛑        |     onlyRole     |
|       └        |          mintBatch          |               Public ❗️                |       🛑        |     onlyRole     |




### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |



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

### Events

#### `Mint(address,uint256)`

##### Definition


```solidity
event Mint(address indexed account, uint256 value)
```

##### Description

Emitted when the specified  `value` amount of new tokens were created and
allocated to the specified `account`.

