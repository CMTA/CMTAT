## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/4_CMTATBaseDebt.sol | b9b2ee6c62a35ed60737592cb48fa8b921bebc4d |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseDebt** | Implementation | CMTATBaseRuleEngine, DebtModule, CMTATBaseSnapshot |||
| └ | approve | Public ❗️ | 🛑  |NO❗️ |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | _update | Internal 🔒 | 🛑  | |
| └ | _authorizeDebtManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeSnapshots | Internal 🔒 | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
