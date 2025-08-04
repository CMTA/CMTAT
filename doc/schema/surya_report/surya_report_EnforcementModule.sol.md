## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/EnforcementModule.sol | a41d1394fee0cbd624d848f7ce479973b114bba9 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **EnforcementModule** | Implementation | EnforcementModuleInternal, AccessControlUpgradeable, IERC3643Enforcement, IERC3643EnforcementEvent |||
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyRole |
| └ | setAddressFrozen | Public ❗️ | 🛑  | onlyRole |
| └ | batchSetAddressFrozen | Public ❗️ | 🛑  | onlyRole |
| └ | isFrozen | Public ❗️ |   |NO❗️ |
| └ | _addAddressToTheList | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
