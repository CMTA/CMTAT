## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/PauseModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **PauseModule** | Implementation | PausableUpgradeable, AuthorizationModule, IERC3643Pause, IERC7551Pause, ICMTATDeactivate |||
| └ | paused | Public ❗️ |   |NO❗️ |
| └ | pause | Public ❗️ | 🛑  | onlyRole |
| └ | unpause | Public ❗️ | 🛑  | onlyRole |
| └ | deactivateContract | Public ❗️ | 🛑  | onlyRole |
| └ | deactivated | Public ❗️ |   |NO❗️ |
| └ | _getPauseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
