## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/DebtModule/CreditEventsModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CreditEventsModule** | Implementation | IDebtGlobal, Initializable, ContextUpgradeable, AuthorizationModule |||
| └ | __CreditEvents_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | setCreditEvents | Public ❗️ | 🛑  | onlyRole |
| └ | setFlagDefault | Public ❗️ | 🛑  | onlyRole |
| └ | setFlagRedeemed | Public ❗️ | 🛑  | onlyRole |
| └ | setRating | Public ❗️ | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
