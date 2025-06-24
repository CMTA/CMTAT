## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/0_CMTATBaseCore.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseCore** | Implementation | Initializable, ContextUpgradeable, BaseModule, ERC20MintModule, ERC20BurnModule, ValidationModuleCore, ERC20BaseModule, IForcedBurnERC20, IBurnMintERC20, IERC7551ERC20EnforcementEvent, AuthorizationModule |||
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | __CMTAT_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_openzeppelin_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_modules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | burnAndMint | Public ❗️ | 🛑  |NO❗️ |
| └ | forcedBurn | Public ❗️ | 🛑  | onlyRole |
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | _mint | Internal 🔒 | 🛑  | |
| └ | _burn | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
