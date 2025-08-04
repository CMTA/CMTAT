## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/PauseModule.sol | b4031025bbd3170e430c9a688d0bd1337b45dccc |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **PauseModule** | Implementation | PausableUpgradeable, AccessControlUpgradeable, IERC3643Pause, IERC7551Pause, ICMTATDeactivate |||
| └ | pause | Public ❗️ | 🛑  | onlyRole |
| └ | unpause | Public ❗️ | 🛑  | onlyRole |
| └ | deactivateContract | Public ❗️ | 🛑  | onlyRole |
| └ | paused | Public ❗️ |   |NO❗️ |
| └ | deactivated | Public ❗️ |   |NO❗️ |
| └ | _getPauseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
