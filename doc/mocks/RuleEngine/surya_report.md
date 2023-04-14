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
| ./mocks/RuleEngine/interfaces/IRuleEngine.sol | 0b68f0da2552a2f420d1c120d08845cc1112caf8 |


#### Contracts Description Table


|    Contract     |       Type        |      Bases      |                |               |
| :-------------: | :---------------: | :-------------: | :------------: | :-----------: |
|        └        | **Function Name** | **Visibility**  | **Mutability** | **Modifiers** |
|                 |                   |                 |                |               |
| **IRuleEngine** |     Interface     | IEIP1404Wrapper |                |               |
|        └        |     setRules      |   External ❗️    |       🛑        |      NO❗️      |
|        └        |    rulesCount     |   External ❗️    |                |      NO❗️      |
|        └        |       rule        |   External ❗️    |                |      NO❗️      |
|        └        |       rules       |   External ❗️    |                |      NO❗️      |



### IRule

#### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/RuleEngine/interfaces/IRule.sol | ba670eb11141a6ff6fb85f83acf2e0bad07e51fd |


#### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **IRule** | Interface | IEIP1404Wrapper |||
| └ | canReturnTransferRestrictionCode | External ❗️ |   |NO❗️ |



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
