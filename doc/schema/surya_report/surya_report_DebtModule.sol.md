## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/DebtModule.sol | 9736762f32486a96d64571276dfc4f727815ade0 |


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
