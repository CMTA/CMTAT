## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/AllowlistModule.sol | 6f01c8e98ebc3a62e0277de391402a527535568e |


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
