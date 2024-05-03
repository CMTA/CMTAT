## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ERC20SnapshotModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20SnapshotModule** | Implementation | ERC20SnapshotModuleInternal, AuthorizationModule |||
| └ | __ERC20SnasphotModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | scheduleSnapshot | Public ❗️ | 🛑  | onlyRole |
| └ | scheduleSnapshotNotOptimized | Public ❗️ | 🛑  | onlyRole |
| └ | rescheduleSnapshot | Public ❗️ | 🛑  | onlyRole |
| └ | unscheduleLastSnapshot | Public ❗️ | 🛑  | onlyRole |
| └ | unscheduleSnapshotNotOptimized | Public ❗️ | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
