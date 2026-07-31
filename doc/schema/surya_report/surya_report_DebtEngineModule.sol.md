## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/DebtEngineModule.sol | bec61266986f0577e064bd1a1c86b11dabf7e988 |


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
