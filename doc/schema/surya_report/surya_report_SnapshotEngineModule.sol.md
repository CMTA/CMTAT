## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/SnapshotEngineModule.sol | eeae2885a97fa544564445d1b3e1646ff34a12a4 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **SnapshotEngineModule** | Implementation | Initializable, ISnapshotEngineModule |||
| └ | __SnapshotEngineModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | setSnapshotEngine | Public ❗️ | 🛑  | onlySnapshooter |
| └ | snapshotEngine | Public ❗️ |   |NO❗️ |
| └ | _setSnapshotEngine | Internal 🔒 | 🛑  | |
| └ | _authorizeSnapshots | Internal 🔒 | 🛑  | |
| └ | _getSnapshotEngineModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
