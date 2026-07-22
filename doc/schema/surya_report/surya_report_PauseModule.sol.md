## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/PauseModule.sol | 9c29b98667b896b61d8e37f59b3dadc89d8549ef |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **PauseModule** | Implementation | PausableUpgradeable, IERC3643Pause, IERC7551Pause, IERC8343 |||
| └ | pause | Public ❗️ | 🛑  | onlyPauseManager |
| └ | unpause | Public ❗️ | 🛑  | onlyPauseManager |
| └ | deactivateContract | Public ❗️ | 🛑  | onlyDeactivateContractManager |
| └ | paused | Public ❗️ |   |NO❗️ |
| └ | deactivated | Public ❗️ |   |NO❗️ |
| └ | _authorizePause | Internal 🔒 | 🛑  | |
| └ | _authorizeDeactivate | Internal 🔒 | 🛑  | |
| └ | _requireNotDeactivated | Internal 🔒 |   | |
| └ | _getPauseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
