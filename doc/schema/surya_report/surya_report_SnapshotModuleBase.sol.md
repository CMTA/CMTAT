## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/library/snapshot/SnapshotModuleBase.sol | 4882381048da33ecf6a714c8df449209308f5077 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **SnapshotModuleBase** | Implementation | Initializable |||
| └ | __SnapshotModuleBase_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | getAllSnapshots | Public ❗️ |   |NO❗️ |
| └ | getNextSnapshots | Public ❗️ |   |NO❗️ |
| └ | _scheduleSnapshot | Internal 🔒 | 🛑  | |
| └ | _scheduleSnapshotNotOptimized | Internal 🔒 | 🛑  | |
| └ | _rescheduleSnapshot | Internal 🔒 | 🛑  | |
| └ | _unscheduleLastSnapshot | Internal 🔒 | 🛑  | |
| └ | _unscheduleSnapshotNotOptimized | Internal 🔒 | 🛑  | |
| └ | _valueAt | Internal 🔒 |   | |
| └ | _updateSnapshot | Internal 🔒 | 🛑  | |
| └ | _setCurrentSnapshot | Internal 🔒 | 🛑  | |
| └ | _lastSnapshot | Private 🔐 |   | |
| └ | _findScheduledSnapshotIndex | Private 🔐 |   | |
| └ | _findScheduledMostRecentPastSnapshot | Private 🔐 |   | |
| └ | _updateAccountSnapshot | Internal 🔒 | 🛑  | |
| └ | _updateTotalSupplySnapshot | Internal 🔒 | 🛑  | |
| └ | _snapshotBalanceOf | Internal 🔒 |   | |
| └ | _snapshotTotalSupply | Internal 🔒 |   | |
| └ | _findAndRevertScheduledSnapshotIndex | Private 🔐 |   | |
| └ | _checkTimeInThePast | Internal 🔒 |   | |
| └ | _checkTimeSnapshotAlreadyDone | Internal 🔒 |   | |
| └ | _getSnapshotModuleBaseStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
