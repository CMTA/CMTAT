## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/PauseModule.sol | 1af52c2f0a418e75c9db436249ee77f334bf4ed3 |


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
| └ | _getPauseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
