# Snapshot Module

This document defines the Snapshot Module for the CMTA Token specification. 

[TOC]

## Rationale

> In relation to distributions or the exercise of rights attached to tokenized securities, it is necessary to determine the number of tokens held by certain users at a certain point in time to allow issuers to carry out certain corporate actions such as dividend or interest payments. 
>
> Such moments are generally referred to in practice as the "record date" or the "record time" (i.e. the time that is relevant to determine the eligibility of security holders for the relevant corporate action). 
>
> The snapshot functions to determine the number of tokens recorded on the various ledger addresses at a specific point in time and to use that information to carry out transactions on-chain.

## Schema

### Inheritance

![surya_inheritance_ERC20SnapshotModule.sol](../../schema/surya_inheritance/surya_inheritance_ERC20SnapshotModule.sol.png)

### UML

![SnapshotModule](../../schema/sol2uml/ERC20SnapshotModule.svg)

### Graph

#### SnapshotModule

![surya_graph_ERC20SnapshotModule.sol](../../schema/surya_graph/surya_graph_ERC20SnapshotModule.sol.png)

## Sūrya's Description Report

### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |

### SnapshotModule

#### Files Description Table


| File Name                                            | SHA-1 Hash                               |
| ---------------------------------------------------- | ---------------------------------------- |
| ./modules/wrapper/extensions/ERC20SnapshotModule.sol | fbe645e4def4944ea02fa9b07ecd3dfe367ff725 |


#### Contracts Description Table


|        Contract         |                 Type                 |                      Bases                       |                |                  |
| :---------------------: | :----------------------------------: | :----------------------------------------------: | :------------: | :--------------: |
|            └            |          **Function Name**           |                  **Visibility**                  | **Mutability** |  **Modifiers**   |
|                         |                                      |                                                  |                |                  |
| **ERC20SnapshotModule** |            Implementation            | ERC20SnapshotModuleInternal, AuthorizationModule |                |                  |
|            └            | __ERC20SnasphotModule_init_unchained |                    Internal 🔒                    |       🛑        | onlyInitializing |
|            └            |           scheduleSnapshot           |                     Public ❗️                     |       🛑        |     onlyRole     |
|            └            |     scheduleSnapshotNotOptimized     |                     Public ❗️                     |       🛑        |     onlyRole     |
|            └            |          rescheduleSnapshot          |                     Public ❗️                     |       🛑        |     onlyRole     |
|            └            |        unscheduleLastSnapshot        |                     Public ❗️                     |       🛑        |     onlyRole     |
|            └            |    unscheduleSnapshotNotOptimized    |                     Public ❗️                     |       🛑        |     onlyRole     |

