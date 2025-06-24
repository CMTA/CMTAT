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
| **PauseModule** | Implementation | PausableUpgradeable, AccessControlUpgradeable, IERC3643Pause, IERC7551Pause, ICMTATDeactivate |||
| └ | paused | Public ❗️ |   |NO❗️ |
| └ | deactivated | Public ❗️ |   |NO❗️ |
| └ | pause | Public ❗️ | 🛑  | onlyRole |
| └ | unpause | Public ❗️ | 🛑  | onlyRole |
| └ | deactivateContract | Public ❗️ | 🛑  | onlyRole |
| └ | _getPauseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
