## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/DebtModule/DebtBaseModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DebtBaseModule** | Implementation | IDebtGlobal, Initializable, ContextUpgradeable, AuthorizationModule |||
| └ | __DebtBaseModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | setDebt | Public ❗️ | 🛑  | onlyRole |
| └ | setInterestRate | Public ❗️ | 🛑  | onlyRole |
| └ | setParValue | Public ❗️ | 🛑  | onlyRole |
| └ | setGuarantor | Public ❗️ | 🛑  | onlyRole |
| └ | setBondHolder | Public ❗️ | 🛑  | onlyRole |
| └ | setMaturityDate | Public ❗️ | 🛑  | onlyRole |
| └ | setInterestScheduleFormat | Public ❗️ | 🛑  | onlyRole |
| └ | setInterestPaymentDate | Public ❗️ | 🛑  | onlyRole |
| └ | setDayCountConvention | Public ❗️ | 🛑  | onlyRole |
| └ | setBusinessDayConvention | Public ❗️ | 🛑  | onlyRole |
| └ | setPublicHolidaysCalendar | Public ❗️ | 🛑  | onlyRole |
| └ | setIssuanceDate | Public ❗️ | 🛑  | onlyRole |
| └ | setCouponFrequency | Public ❗️ | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
