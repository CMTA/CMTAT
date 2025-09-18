## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/ERC20BaseModule.sol | dbfc430335786836dd8b73e0a34dacc69202aa73 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20BaseModule** | Implementation | ERC20Upgradeable, IERC20Allowance, IERC3643ERC20Base, IERC20BatchBalance |||
| └ | __ERC20BaseModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | setName | Public ❗️ | 🛑  | onlyERC20AttributeManager |
| └ | setSymbol | Public ❗️ | 🛑  | onlyERC20AttributeManager |
| └ | batchBalanceOf | Public ❗️ |   |NO❗️ |
| └ | _authorizeERC20AttributeManagement | Internal 🔒 | 🛑  | |
| └ | _getERC20BaseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
