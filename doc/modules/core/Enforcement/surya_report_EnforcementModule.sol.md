## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/EnforcementModule.sol | ffea175fbf940073568bf4414dceefcd5bdefed8 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **EnforcementModule** | Implementation | EnforcementModuleInternal, IERC3643Enforcement, IERC3643EnforcementEvent |||
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyEnforcer |
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyEnforcer |
| └ | batchSetAddressFrozen | Public ❗️ | 🛑  | onlyEnforcer |
| └ | isFrozen | Public ❗️ |   |NO❗️ |
| └ | _addAddressToTheList | Internal 🔒 | 🛑  | |
| └ | _authorizeFreeze | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
