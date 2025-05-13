## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/DebtModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DebtModule** | Implementation | AuthorizationModule, ICMTATDebt |||
| └ | __DebtModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | setDebt | External ❗️ | 🛑  | onlyRole |
| └ | debt | Public ❗️ |   |NO❗️ |
| └ | _getDebtModuleStorage | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
