## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/DebtEngineModule.sol | b30b55f3f6cbe7c55f0c7eca58020064ec56be9a |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DebtEngineModule** | Implementation | IDebtEngineModule |||
| └ | setDebtEngine | Public ❗️ | 🛑  | onlyDebtEngineManager |
| └ | creditEvents | Public ❗️ |   |NO❗️ |
| └ | debt | Public ❗️ |   |NO❗️ |
| └ | debtEngine | Public ❗️ |   |NO❗️ |
| └ | _setDebtEngine | Internal 🔒 | 🛑  | |
| └ | _authorizeDebtEngineManagement | Internal 🔒 | 🛑  | |
| └ | _getDebtEngineModuleStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
