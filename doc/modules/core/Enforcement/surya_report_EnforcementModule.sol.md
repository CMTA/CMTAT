## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/EnforcementModule.sol | 4d80a37d5b8f4b1c675f237e0863cb5dc4cd9c3d |


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
