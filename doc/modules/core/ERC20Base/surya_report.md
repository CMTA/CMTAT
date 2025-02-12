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
| **ERC20BaseModule** | Implementation | ERC20Upgradeable, AuthorizationModule |||
| └ | __ERC20BaseModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | transferBatch | Public ❗️ | 🛑  |NO❗️ |
| └ | balanceInfo | Public ❗️ |   |NO❗️ |
| └ | setName | Public ❗️ | 🛑  | onlyRole |
| └ | setSymbol | Public ❗️ | 🛑  | onlyRole |
| └ | enforceTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | _getERC20BaseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
