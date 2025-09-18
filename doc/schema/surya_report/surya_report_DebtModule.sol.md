## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/DebtModule.sol | 7db3012ecd1c49a9175098811c8bc04e6fc2c8f8 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DebtModule** | Implementation | IDebtModule |||
| └ | setCreditEvents | Public ❗️ | 🛑  | onlyDebtManager |
| └ | setDebt | Public ❗️ | 🛑  | onlyDebtManager |
| └ | setDebtInstrument | Public ❗️ | 🛑  | onlyDebtManager |
| └ | creditEvents | Public ❗️ |   |NO❗️ |
| └ | debt | Public ❗️ |   |NO❗️ |
| └ | _authorizeDebtManagement | Internal 🔒 | 🛑  | |
| └ | _getDebtModuleStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
