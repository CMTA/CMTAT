## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/controllers/ValidationEngineModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModule** | Implementation | Initializable, ContextUpgradeable, PauseModule, EnforcementModule, IERC1404Wrapper |||
| └ | __ValidationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | ruleEngine | Public ❗️ |   |NO❗️ |
| └ | setRuleEngine | External ❗️ | 🛑  | onlyRole |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | validateTransfer | Public ❗️ |   |NO❗️ |
| └ | _validateTransfer | Internal 🔒 |   | |
| └ | _validateTransferByModule | Internal 🔒 |   | |
| └ | _setRuleEngine | Internal 🔒 | 🛑  | |
| └ | _operateOnTransfer | Internal 🔒 | 🛑  | |
| └ | _getValidationModuleInternalStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
