## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/PauseModule.sol | 0980a0d824c410ca19ee321e50b766924453fd56 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **PauseModule** | Implementation | PausableUpgradeable, IERC3643Pause, IERC7551Pause, ICMTATDeactivate |||
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
