## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/security/AuthorizationModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **AuthorizationModule** | Implementation | AccessControlUpgradeable |||
| └ | __AuthorizationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | authorizationEngine | Public ❗️ |   |NO❗️ |
| └ | setAuthorizationEngine | External ❗️ | 🛑  | onlyRole |
| └ | grantRole | Public ❗️ | 🛑  | onlyRole |
| └ | revokeRole | Public ❗️ | 🛑  | onlyRole |
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | _getAuthorizationModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
