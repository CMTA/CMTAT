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
| **ValidationModule** | Implementation | Initializable, ContextUpgradeable, PauseModule, EnforcementModule, IERC1404, IERC3643ComplianceRead, IERC7551Compliance |||
| └ | __ValidationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | ruleEngine | Public ❗️ |   |NO❗️ |
| └ | setRuleEngine | Public ❗️ | 🛑  | onlyRole |
| └ | messageForTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | canMint | Public ❗️ |   |NO❗️ |
| └ | canBurn | Public ❗️ |   |NO❗️ |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canApprove | Public ❗️ |   |NO❗️ |
| └ | _canTransfer | Internal 🔒 |   | |
| └ | _canMintByModule | Internal 🔒 |   | |
| └ | _canBurnByModule | Internal 🔒 |   | |
| └ | _canTransferByModule | Internal 🔒 |   | |
| └ | _setRuleEngine | Internal 🔒 | 🛑  | |
| └ | _operateOnTransfer | Internal 🔒 | 🛑  | |
| └ | _canApprove | Internal 🔒 |   | |
| └ | _getValidationModuleInternalStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
