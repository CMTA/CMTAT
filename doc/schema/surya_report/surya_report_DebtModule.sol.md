## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/DebtModule.sol | 65ce6028f5c056b4d76eeb98071596230281a359 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DebtModule** | Implementation | AccessControlUpgradeable, IDebtModule |||
| └ | setCreditEvents | Public ❗️ | 🛑  | onlyRole |
| └ | setDebt | Public ❗️ | 🛑  | onlyRole |
| └ | setDebtInstrument | Public ❗️ | 🛑  | onlyRole |
| └ | creditEvents | Public ❗️ |   |NO❗️ |
| └ | debt | Public ❗️ |   |NO❗️ |
| └ | _getDebtModuleStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
