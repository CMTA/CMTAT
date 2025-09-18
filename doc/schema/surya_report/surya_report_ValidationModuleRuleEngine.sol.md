## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol | a19e2c67c3f589d1874f67a4e4b7b6e7d09b7883 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModuleRuleEngine** | Implementation | ValidationModuleCore, ValidationModuleRuleEngineInternal |||
| └ | setRuleEngine | Public ❗️ | 🛑  | onlyRuleEngineManager |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |
| └ | _canTransfer | Internal 🔒 |   | |
| └ | _canTransferFrom | Internal 🔒 |   | |
| └ | _canTransferFromWithRuleEngine | Internal 🔒 |   | |
| └ | _canTransferWithRuleEngine | Internal 🔒 |   | |
| └ | _authorizeRuleEngineManagement | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
