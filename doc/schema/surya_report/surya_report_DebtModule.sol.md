## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/DebtModule.sol | 9a1410e5d2b6c34a0fad40b7f7f752b9da7b11ce |


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
