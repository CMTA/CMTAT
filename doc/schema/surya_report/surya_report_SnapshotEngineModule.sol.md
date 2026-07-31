## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/SnapshotEngineModule.sol | 97a00d213b2e9d6122c7197f64a7d0d26f0d9adb |


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
