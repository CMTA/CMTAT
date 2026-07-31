## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/SnapshotEngineMock.sol | 6a3f7d58163a1da7d3cecad6b14a0276c70b5b07 |


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
