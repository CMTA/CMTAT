## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/internal/ERC20SnapshotModuleInternal.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20SnapshotModuleInternal** | Implementation | SnapshotModuleBase, ERC20Upgradeable |||
| └ | __ERC20Snapshot_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | _snapshotUpdate | Internal 🔒 | 🛑  | |
| └ | _updateAccountSnapshot | Private 🔐 | 🛑  | |
| └ | _updateTotalSupplySnapshot | Private 🔐 | 🛑  | |
| └ | getSnapshotInfoBatch | Public ❗️ |   |NO❗️ |
| └ | snapshotBalanceOf | Public ❗️ |   |NO❗️ |
| └ | snapshotTotalSupply | Public ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
