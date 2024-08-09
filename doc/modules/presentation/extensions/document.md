# Document Module

This document defines  Document Module for the CMTA Token specification.

[TOC]

## Schema

### Inheritance

![surya_inheritance_DebtBaseModule.sol](../../../schema/surya_inheritance/surya_inheritance_DocumentModule.sol.png)





### Graph

![surya_graph_DebtBaseModule.sol](../../../schema/surya_graph/surya_graph_DocumentModule.sol.png)

## Sūrya's Description Report

|      | [object Promise] |
| ---- | ---------------- |


### Contracts Description Table


|      Contract      |              Type               |             Bases             |                |                  |
| :----------------: | :-----------------------------: | :---------------------------: | :------------: | :--------------: |
|         └          |        **Function Name**        |        **Visibility**         | **Mutability** |  **Modifiers**   |
|                    |                                 |                               |                |                  |
| **DocumentModule** |         Implementation          | AuthorizationModule, IERC1643 |                |                  |
|         └          | __DocumentModule_init_unchained |          Internal 🔒           |       🛑        | onlyInitializing |
|         └          |         documentEngine          |           Public ❗️            |                |       NO❗️        |
|         └          |        setDocumentEngine        |          External ❗️           |       🛑        |     onlyRole     |
|         └          |           getDocument           |           Public ❗️            |                |       NO❗️        |
|         └          |         getAllDocuments         |           Public ❗️            |                |       NO❗️        |
|         └          |    _getDocumentModuleStorage    |           Private 🔐           |                |                  |


### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |

## API for Ethereum

This section describes the Ethereum API of Document Module.

<To do>
