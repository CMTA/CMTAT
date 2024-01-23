## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/internal/base/SnapshotModuleBase.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **SnapshotModuleBase** | Implementation | Initializable |||
| └ | __SnapshotModuleBase_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | _scheduleSnapshot | Internal 🔒 | 🛑  | |
| └ | _scheduleSnapshotNotOptimized | Internal 🔒 | 🛑  | |
| └ | _rescheduleSnapshot | Internal 🔒 | 🛑  | |
| └ | _unscheduleLastSnapshot | Internal 🔒 | 🛑  | |
| └ | _unscheduleSnapshotNotOptimized | Internal 🔒 | 🛑  | |
| └ | getNextSnapshots | Public ❗️ |   |NO❗️ |
| └ | getAllSnapshots | Public ❗️ |   |NO❗️ |
| └ | _valueAt | Internal 🔒 |   | |
| └ | _updateSnapshot | Internal 🔒 | 🛑  | |
| └ | _setCurrentSnapshot | Internal 🔒 | 🛑  | |
| └ | _lastSnapshot | Private 🔐 |   | |
| └ | _findScheduledSnapshotIndex | Private 🔐 |   | |
| └ | _findScheduledMostRecentPastSnapshot | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
