## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/EnforcementModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **EnforcementModule** | Implementation | EnforcementModuleInternal, AccessControlUpgradeable, IERC3643Enforcement, IERC3643EnforcementEvent |||
| └ | isFrozen | Public ❗️ |   |NO❗️ |
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyRole |
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyRole |
| └ | batchSetAddressFrozen | Public ❗️ | 🛑  | onlyRole |
| └ | _addAddressToTheList | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
