# Base Module

This document defines Base Module for the CMTA Token specification.

[TOC]

## Rationale

The Base Module sets forth the basic functionalities a token must have to comply with the CMTAT framework, for tokens representing equity securities as well as tokens representing and debt securities. 

## Schema

### Inheritance

![surya_inheritance_BaseModule.sol](../../schema/surya_inheritance/surya_inheritance_BaseModule.sol.png)

### UML

![BaseModule](../../schema/sol2uml/mandatory/BaseModule.svg)

### Graph

![surya_graph_BaseModule.sol](../../schema/surya_graph/surya_graph_BaseModule.sol.png)

## Sūrya's Description Report

### Files Description Table


| File Name                                  | SHA-1 Hash                               |
| ------------------------------------------ | ---------------------------------------- |
| ./modules/wrapper/mandatory/BaseModule.sol | 2f3dff2a6760314b7469f2c1e95edc2a73709359 |


### Contracts Description Table


|    Contract    |         Type          |                    Bases                    |                |                           |
| :------------: | :-------------------: | :-----------------------------------------: | :------------: | :-----------------------: |
|       └        |   **Function Name**   |               **Visibility**                | **Mutability** |       **Modifiers**       |
|                |                       |                                             |                |                           |
| **BaseModule** |    Implementation     | AuthorizationModule, OnlyDelegateCallModule |                |                           |
|       └        |      __Base_init      |                 Internal 🔒                  |       🛑        |     onlyInitializing      |
|       └        | __Base_init_unchained |                 Internal 🔒                  |       🛑        |     onlyInitializing      |
|       └        |      setTokenId       |                  Public ❗️                   |       🛑        |         onlyRole          |
|       └        |       setTerms        |                  Public ❗️                   |       🛑        |         onlyRole          |
|       └        |    setInformation     |                  Public ❗️                   |       🛑        |         onlyRole          |
|       └        |        setFlag        |                  Public ❗️                   |       🛑        |         onlyRole          |
|       └        |         kill          |                  Public ❗️                   |       🛑        | onlyRole onlyDelegateCall |


### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |



## API for Ethereum

### Functions

#### `setTokenId(string)`

##### Definiton:

```solidity
function setTokenId(string memory tokenId_) public
```

##### Description:

Set the `token id` to the given `string`.
Only authorized users are allowed to call this function.

#### `setTerms(string)`

##### Definition:

```solidity
function setTerms(string memory terms_) 
public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the `terms` to the given `string`.
Only authorized users are allowed to call this function.

#### `setInformation(string)`

##### Definition:

```solidity
function setInformation(string memory information_) 
public onlyRole(DEFAULT_ADMIN_ROLE) 
```

##### Description:

Set the information` to the given `uint256`.
Only authorized users are allowed to call this function.

#### `setFlag(uint256)`

##### Definition:

```solidity
function setFlag(uint256 flag_) 
public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the `flag` to the given `uint256`.
Only authorized users are allowed to call this function.

#### `kill`

##### Definition:

```solidity
function kill()
public onlyRole(DEFAULT_ADMIN_ROLE) onlyDelegateCall(deployedWithProxy)
```

##### Description:

Destroys the contract, send the remaining ethers to msg.sender

### Events

#### `Term(string)`

##### Definiton:

```solidity
event Term(string indexed newTermIndexed, string newTerm)
```

##### Description:

Emitted when the variable `terms` is set to `newTerm`.

#### `tokenId`

##### Definiton:

```solidity
event TokenId(string indexed newTokenIdIndexed, string newTokenId)
```

##### Description:

Emitted when `tokenId` is set to `newTokenId`.

#### `Information(string,string)`

##### Definiton:

```solidity
event Information(string indexed newInformationIndexed, string newInformation)
```

##### Description:

Emitted when the variable `information` is set to `newInformation`.

#### `Flag(uint256)`

##### Definiton:

```solidity
event Flag(uint256 indexed newFlag)
```

##### Description:

Emitted when the variable `flag` is set to `newFlag`.
