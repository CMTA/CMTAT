# Sūrya's Description Report

[TOC]



## Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |

## Interface

### IRuleEngine

#### Files Description Table


| File Name                                     | SHA-1 Hash                               |
| --------------------------------------------- | ---------------------------------------- |
| ./mocks/RuleEngine/interfaces/IRuleEngine.sol | 80bd43fefabf7d1d9209b285775377a1d5fb26d6 |


#### Contracts Description Table


|    Contract     |       Type        |      Bases      |                |               |
| :-------------: | :---------------: | :-------------: | :------------: | :-----------: |
|        └        | **Function Name** | **Visibility**  | **Mutability** | **Modifiers** |
|                 |                   |                 |                |               |
| **IRuleEngine** |     Interface     | IERC1404Wrapper |                |               |
|        └        |     setRules      |   External ❗️    |       🛑        |      NO❗️      |
|        └        |    rulesCount     |   External ❗️    |                |      NO❗️      |
|        └        |       rule        |   External ❗️    |                |      NO❗️      |
|        └        |       rules       |   External ❗️    |                |      NO❗️      |



### IRule

#### Files Description Table


| File Name                               | SHA-1 Hash                               |
| --------------------------------------- | ---------------------------------------- |
| ./mocks/RuleEngine/interfaces/IRule.sol | 5ae93a4b64d88e12435538f315d1ca5724bc8718 |


#### Contracts Description Table


| Contract  |               Type               |      Bases      |                |               |
| :-------: | :------------------------------: | :-------------: | :------------: | :-----------: |
|     └     |        **Function Name**         | **Visibility**  | **Mutability** | **Modifiers** |
|           |                                  |                 |                |               |
| **IRule** |            Interface             | IERC1404Wrapper |                |               |
|     └     | canReturnTransferRestrictionCode |   External ❗️    |                |      NO❗️      |



## Implementation

### RuleEngineMock

#### Files Description Table


| File Name                             | SHA-1 Hash                               |
| ------------------------------------- | ---------------------------------------- |
| ./mocks/RuleEngine/RuleEngineMock.sol | 91baf6105f61c91bfa3c44c47c11d0d08b80d080 |


#### Contracts Description Table


|      Contract      |             Type              |         Bases         |                |               |
| :----------------: | :---------------------------: | :-------------------: | :------------: | :-----------: |
|         └          |       **Function Name**       |    **Visibility**     | **Mutability** | **Modifiers** |
|                    |                               |                       |                |               |
| **RuleEngineMock** |        Implementation         | IRuleEngine, CodeList |                |               |
|         └          |         <Constructor>         |       Public ❗️        |       🛑        |      NO❗️      |
|         └          |           setRules            |      External ❗️       |       🛑        |      NO❗️      |
|         └          |          rulesCount           |      External ❗️       |                |      NO❗️      |
|         └          |             rule              |      External ❗️       |                |      NO❗️      |
|         └          |             rules             |      External ❗️       |                |      NO❗️      |
|         └          |   detectTransferRestriction   |       Public ❗️        |                |      NO❗️      |
|         └          |       validateTransfer        |       Public ❗️        |                |      NO❗️      |
|         └          | messageForTransferRestriction |       Public ❗️        |                |      NO❗️      |



### RuleMock

#### Files Description Table


| File Name                       | SHA-1 Hash                               |
| ------------------------------- | ---------------------------------------- |
| ./mocks/RuleEngine/RuleMock.sol | 38a30907243a0f91241a792d2d36479c46e3f999 |


#### Contracts Description Table


|   Contract   |               Type               |      Bases      |                |               |
| :----------: | :------------------------------: | :-------------: | :------------: | :-----------: |
|      └       |        **Function Name**         | **Visibility**  | **Mutability** | **Modifiers** |
|              |                                  |                 |                |               |
| **RuleMock** |          Implementation          | IRule, CodeList |                |               |
|      └       |         validateTransfer         |    Public ❗️     |                |      NO❗️      |
|      └       |    detectTransferRestriction     |    Public ❗️     |                |      NO❗️      |
|      └       | canReturnTransferRestrictionCode |    Public ❗️     |                |      NO❗️      |
|      └       |  messageForTransferRestriction   |   External ❗️    |                |      NO❗️      |
