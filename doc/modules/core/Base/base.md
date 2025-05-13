# Base Module

This document defines Base Module for the CMTA Token specification.

[TOC]

## Rationale

> The Base Module set the basic properties common to the different CMTAT tokens.
>
> Currently it only stores the contract version with the ERC-3643 function to retrieve it (`version`)
>

## Schema

### Inheritance

![surya_inheritance_BaseModule.sol](../../../schema/surya_inheritance/surya_inheritance_BaseModule.sol.png)

### Graph

![surya_graph_BaseModule.sol](../../../schema/surya_graph/surya_graph_BaseModule.sol.png)



## API for Ethereum

### Functions

#### `version`

##### Definition:

```solidity
function version() public view virtual override(IERC3643Base) returns (string memory)
```

##### Description:

return the current contract version

### Files Description Table


| File Name                             | SHA-1 Hash                               |
| ------------------------------------- | ---------------------------------------- |
| ./modules/wrapper/core/BaseModule.sol | 88c3e7f8f49a491cc6432472783d33ac3127d536 |


### Contracts Description Table


|    Contract    |         Type          |        Bases        |                |                  |
| :------------: | :-------------------: | :-----------------: | :------------: | :--------------: |
|       └        |   **Function Name**   |   **Visibility**    | **Mutability** |  **Modifiers**   |
|                |                       |                     |                |                  |
| **BaseModule** |    Implementation     | AuthorizationModule |                |                  |
|       └        |      __Base_init      |     Internal 🔒      |       🛑        | onlyInitializing |
|       └        | __Base_init_unchained |     Internal 🔒      |       🛑        | onlyInitializing |
|       └        |      setTokenId       |      Public ❗️       |       🛑        |     onlyRole     |
|       └        |       setTerms        |      Public ❗️       |       🛑        |     onlyRole     |
|       └        |    setInformation     |      Public ❗️       |       🛑        |     onlyRole     |
|       └        |        setFlag        |      Public ❗️       |       🛑        |     onlyRole     |

### Events

#### `Term(string)`

##### Definition:

```solidity
event Term(string indexed newTermIndexed, string newTerm)
```

##### Description:

Emitted when the variable `terms` is set to `newTerm`.

#### `tokenId(string,string`

##### Definition:

```solidity
event TokenId(string indexed newTokenIdIndexed, string newTokenId)
```

##### Description:

Emitted when `tokenId` is set to `newTokenId`.

#### `Information(string,string)`

##### Definition:

```solidity
event Information(string indexed newInformationIndexed, string newInformation)
```

##### Description:

Emitted when the variable `information` is set to `newInformation`.
