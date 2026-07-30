## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/PauseModule.sol | 1d64c6a87cf4b13ab7d2a4980b8c1d82a5a29f6c |


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
