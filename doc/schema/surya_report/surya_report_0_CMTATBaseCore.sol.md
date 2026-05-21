## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/0_CMTATBaseCore.sol | 6e879243185b8c9f76fcedb367b2aee8b27ba60e |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseCore** | Implementation | Initializable, ContextUpgradeable, VersionModule, ERC20MintModule, ERC20BurnModule, ValidationModuleAllowance, ERC20BaseModule, AccessControlModule, IForcedBurnERC20, IBurnMintERC20, IERC7551ERC20EnforcementEvent, IERC5679, IERC7943FungibleTransferError |||
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | __CMTAT_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_openzeppelin_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_modules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | approve | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | burnAndMint | Public ❗️ | 🛑  |NO❗️ |
| └ | forcedBurn | Public ❗️ | 🛑  | onlyERC20ForcedBurnManager |
| └ | _mintOverride | Internal 🔒 | 🛑  | |
| └ | _burnOverride | Internal 🔒 | 🛑  | |
| └ | _minterTransferOverride | Internal 🔒 | 🛑  | |
| └ | _authorizeForcedBurn | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeMint | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeBurn | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizePause | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeDeactivate | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeFreeze | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeERC20AttributeManagement | Internal 🔒 | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
