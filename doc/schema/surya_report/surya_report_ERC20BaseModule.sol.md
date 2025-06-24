## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/ERC20BaseModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20BaseModule** | Implementation | ERC20Upgradeable, AccessControlUpgradeable, IERC20Allowance, IERC3643ERC20Base, IERC20BatchBalance |||
| └ | __ERC20BaseModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | batchBalanceOf | Public ❗️ |   |NO❗️ |
| └ | setName | Public ❗️ | 🛑  | onlyRole |
| └ | setSymbol | Public ❗️ | 🛑  | onlyRole |
| └ | _getERC20BaseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
