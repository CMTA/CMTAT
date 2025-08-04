## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/AllowlistModule.sol | b77177dc4041d6d04497d5dc38cbc841e9546d9b |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **AllowlistModule** | Implementation | AllowlistModuleInternal, AccessControlUpgradeable, IAllowlistModule |||
| └ | setAddressAllowlist | Public ❗️ | 🛑  | onlyRole |
| └ | setAddressAllowlist | Public ❗️ | 🛑  | onlyRole |
| └ | batchSetAddressAllowlist | Public ❗️ | 🛑  | onlyRole |
| └ | enableAllowlist | Public ❗️ | 🛑  | onlyRole |
| └ | isAllowlistEnabled | Public ❗️ |   |NO❗️ |
| └ | isAllowlisted | Public ❗️ |   |NO❗️ |
| └ | _addToAllowlist | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
