## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/AllowlistModule.sol | 8614cd7c3084cf25cbbdf7d0efcb68473054be2a |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **AllowlistModule** | Implementation | AllowlistModuleInternal, IAllowlistModule |||
| └ | setAddressAllowlist | Public ❗️ | 🛑  | onlyAllowlistManager |
| └ | setAddressAllowlist | Public ❗️ | 🛑  | onlyAllowlistManager |
| └ | batchSetAddressAllowlist | Public ❗️ | 🛑  | onlyAllowlistManager |
| └ | enableAllowlist | Public ❗️ | 🛑  | onlyAllowlistManager |
| └ | isAllowlistEnabled | Public ❗️ |   |NO❗️ |
| └ | isAllowlisted | Public ❗️ |   |NO❗️ |
| └ | _addToAllowlist | Internal 🔒 | 🛑  | |
| └ | _authorizeAllowlistManagement | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
