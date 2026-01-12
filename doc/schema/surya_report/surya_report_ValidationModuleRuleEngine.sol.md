## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol | 51e9f0eec70789922ff3f9cebdf7a5b3a1c25ae9 |


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
