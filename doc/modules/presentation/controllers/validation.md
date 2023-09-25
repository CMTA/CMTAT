# Validation Module

This document defines the Validation Module for the CMTA Token specification. The goal of the Validation Module is to restrict token transferability based on a set of rules applied to the token.

[TOC]

## Rationale

> Issuers may decide to implement legal restrictions to the transfer of the tokenized instruments, to limit the scope of persons or entities who may hold the relevant instruments. 

## Schema

### Inheritance

#### ValidationModule

![surya_inheritance_ValidationModule.sol](../../../schema/surya_inheritance/surya_inheritance_ValidationModule.sol.png)

#### ValidationModuleInternal

![surya_inheritance_ValidationModuleInternal.sol](../../../schema/surya_inheritance/surya_inheritance_ValidationModuleInternal.sol.png)

### UML

![ValidationModule](../../../schema/sol2uml/ValidationModule.svg)

### Graph

#### ValidationModule

![surya_graph_ValidationModule.sol](../../../schema/surya_graph/surya_graph_ValidationModule.sol.png)

#### ValidationModuleInternal

![surya_graph_ValidationModuleInternal.sol](../../../schema/surya_graph/surya_graph_ValidationModuleInternal.sol.png)



## Sūrya's Description Report

### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |

### ValidationModule

#### Files Description Table


| File Name                                         | SHA-1 Hash                               |
| ------------------------------------------------- | ---------------------------------------- |
| ./modules/wrapper/controller/ValidationModule.sol | 109054150a46ef0f010693889f9c1c44e151719b |


#### Contracts Description Table


|       Contract       |               Type                |                            Bases                             |                |                  |
| :------------------: | :-------------------------------: | :----------------------------------------------------------: | :------------: | :--------------: |
|          └           |         **Function Name**         |                        **Visibility**                        | **Mutability** |  **Modifiers**   |
|                      |                                   |                                                              |                |                  |
| **ValidationModule** |          Implementation           | ValidationModuleInternal, PauseModule, EnforcementModule, IEIP1404Wrapper |                |                  |
|          └           |      __ValidationModule_init      |                          Internal 🔒                          |       🛑        | onlyInitializing |
|          └           | __ValidationModule_init_unchained |                          Internal 🔒                          |       🛑        | onlyInitializing |
|          └           |           setRuleEngine           |                          External ❗️                          |       🛑        |     onlyRole     |
|          └           |     detectTransferRestriction     |                           Public ❗️                           |                |       NO❗️        |
|          └           |   messageForTransferRestriction   |                          External ❗️                          |                |       NO❗️        |
|          └           |         validateTransfer          |                           Public ❗️                           |                |       NO❗️        |

### ValidationModuleInternal

#### Files Description Table


| File Name                                       | SHA-1 Hash                               |
| ----------------------------------------------- | ---------------------------------------- |
| ./modules/internal/ValidationModuleInternal.sol | 7520ea131a1c5befcc07ff41eada7406ab745850 |


#### Contracts Description Table


|           Contract           |              Type              |               Bases               |                |                  |
| :--------------------------: | :----------------------------: | :-------------------------------: | :------------: | :--------------: |
|              └               |       **Function Name**        |          **Visibility**           | **Mutability** |  **Modifiers**   |
|                              |                                |                                   |                |                  |
| **ValidationModuleInternal** |         Implementation         | Initializable, ContextUpgradeable |                |                  |
|              └               |       __Validation_init        |            Internal 🔒             |       🛑        | onlyInitializing |
|              └               |  __Validation_init_unchained   |            Internal 🔒             |       🛑        | onlyInitializing |
|              └               |       _validateTransfer        |            Internal 🔒             |                |                  |
|              └               | _messageForTransferRestriction |            Internal 🔒             |                |                  |
|              └               |   _detectTransferRestriction   |            Internal 🔒             |                |                  |

## API for Ethereum

This section describes the Ethereum API of the Validation Module.

The rules are defined using an (optional) rule engine, set using the `setRuleEngine` method. The `RuleEngine` implementation is not provided along with this implementation but it has to comply with the interface [IRuleEngine](https://github.com/CMTA/CMTAT/blob/master/contracts/interfaces/IRuleEngine.sol). The RuleEgine call rules that must respect the interface [IRule](https://github.com/CMTA/CMTAT/blob/master/contracts/interfaces/IRule.sol)

### Functions

#### `setRuleEngine(address)`

##### Definition:

```solidity
function setRuleEngine(IEIP1404Wrapper ruleEngine_) 
external onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional rule engine to the given `address`.
Only authorized users are allowed to call this function.

### Events

#### `RuleEngine(address)`

##### Definition:

```solidity
event RuleEngine(IEIP1404Wrapper indexed newRuleEngine)
```

##### Description:

Emitted when the rule engine is set to `newRuleEngine`.
