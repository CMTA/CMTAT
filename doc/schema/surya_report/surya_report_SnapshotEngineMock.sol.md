## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/SnapshotEngineMock.sol | ab18b240f491a0a287ff7c8843585b5ab99eab96 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **SnapshotEngineMock** | Implementation | SnapshotModuleBase, AccessControlUpgradeable, ISnapshotEngine |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | setERC20 | Public ❗️ | 🛑  |NO❗️ |
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | operateOnTransfer | Public ❗️ | 🛑  |NO❗️ |
| └ | snapshotInfo | Public ❗️ |   |NO❗️ |
| └ | snapshotInfoBatch | Public ❗️ |   |NO❗️ |
| └ | snapshotInfoBatch | Public ❗️ |   |NO❗️ |
| └ | snapshotBalanceOf | Public ❗️ |   |NO❗️ |
| └ | snapshotTotalSupply | Public ❗️ |   |NO❗️ |
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
