## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/TokenAttributeModule.sol | de60d9cb13d34bd78647777a55e3ebaff3c323a4 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **TokenAttributeModule** | Implementation | Initializable, IERC3643ERC20Base |||
| └ | __TokenAttributeModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | setName | Public ❗️ | 🛑  | onlyTokenAttributeManager |
| └ | setSymbol | Public ❗️ | 🛑  | onlyTokenAttributeManager |
| └ | _authorizeTokenAttributeManagement | Internal 🔒 | 🛑  | |
| └ | _getTokenAttributeModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
