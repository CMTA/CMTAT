## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/EnforcementModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **EnforcementModule** | Implementation | EnforcementModuleInternal, AuthorizationModule, IERC3643Enforcement, ICMTATEnforcement |||
| └ | __EnforcementModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | isFrozen | Public ❗️ |   |NO❗️ |
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyRole |
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
