## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/ERC20BurnModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20BurnModule** | Implementation | ERC20Upgradeable, ICCIPBurnFromERC20, AuthorizationModule |||
| └ | __ERC20BurnModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | burn | Public ❗️ | 🛑  | onlyRole |
| └ | burnBatch | Public ❗️ | 🛑  | onlyRole |
| └ | burnFrom | Public ❗️ | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
