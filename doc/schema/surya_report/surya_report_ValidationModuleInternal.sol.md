## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/internal/ValidationModuleInternal.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModuleInternal** | Implementation | Initializable, ContextUpgradeable, ValidationModuleInternalCore |||
| └ | __ValidationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | ruleEngine | Public ❗️ |   |NO❗️ |
| └ | setRuleEngine | Public ❗️ | 🛑  | onlyRole |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |
| └ | _canTransferFromWithRuleEngine | Internal 🔒 |   | |
| └ | _canTransferWithRuleEngine | Internal 🔒 |   | |
| └ | _setRuleEngine | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |
| └ | _getValidationModuleInternalStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
