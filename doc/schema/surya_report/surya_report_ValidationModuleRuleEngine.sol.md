## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModuleRuleEngine** | Implementation | ValidationModuleCore, ValidationModuleRuleEngineInternal |||
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |
| └ | setRuleEngine | Public ❗️ | 🛑  | onlyRole |
| └ | _canTransfer | Internal 🔒 |   | |
| └ | _canTransferFrom | Internal 🔒 |   | |
| └ | _canTransferFromWithRuleEngine | Internal 🔒 |   | |
| └ | _canTransferWithRuleEngine | Internal 🔒 |   | |
| └ | _transferred | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
