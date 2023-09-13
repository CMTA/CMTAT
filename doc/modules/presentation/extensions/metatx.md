# MetaTx Module

This document defines the MetaTx Module for the CMTA Token specification. The goal of the MetaTx Module is to enable wallets to transfer tokens without having native tokens in their wallet.

[TOC]

## Rationale

> Support for transaction fee transfer, also known as "gasless transactions" in the Ethereum context.

## Schema

### Inheritance

![surya_inheritance_MetaTxModule.sol](../../schema/surya_inheritance/surya_inheritance_MetaTxModule.sol.png)

### UML

![MetaTxModule](../../schema/sol2uml/optional/MetaTxModule.svg)

### Graph

![surya_graph_MetaTxModule.sol](../../schema/surya_graph/surya_graph_MetaTxModule.sol.png)

## Sūrya's Description Report

### Files Description Table


| File Name                                   | SHA-1 Hash                               |
| ------------------------------------------- | ---------------------------------------- |
| ./modules/wrapper/optional/MetaTxModule.sol | 8a347f1431a6f387045494ea5c7407e6d89d6772 |


### Contracts Description Table


|     Contract     |       Type        |           Bases           |                |                           |
| :--------------: | :---------------: | :-----------------------: | :------------: | :-----------------------: |
|        └         | **Function Name** |      **Visibility**       | **Mutability** |       **Modifiers**       |
|                  |                   |                           |                |                           |
| **MetaTxModule** |  Implementation   | ERC2771ContextUpgradeable |                |                           |
|        └         |   <Constructor>   |         Public ❗️          |       🛑        | ERC2771ContextUpgradeable |
|        └         |    _msgSender     |        Internal 🔒         |                |                           |
|        └         |     _msgData      |        Internal 🔒         |                |                           |


### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |



## API for Ethereum

This section describes the Ethereum API of the MetaTx Module. 

This modules uses ERC2771 implementation from OpenZeppelin: [https://docs.openzeppelin.com/contracts/4.x/api/metatx](https://docs.openzeppelin.com/contracts/4.x/api/metatx)

### Functions

Origin: OpenZeppelin

#### `isTrustedForwarder(address)`

##### Signature:

```solidity
function isTrustedForwarder(address forwarder) 
public view virtual 
returns (bool) 
```

##### Description:

Return `true`if the address put in parameter is the forwarder of the contract, false otherwise
