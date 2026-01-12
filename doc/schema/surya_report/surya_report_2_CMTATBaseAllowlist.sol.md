## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/2_CMTATBaseAllowlist.sol | d2f26a3723557900754a1d49f3bc32e6de5d6b8a |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseAllowlist** | Implementation | Initializable, ContextUpgradeable, CMTATBaseAccessControl, ValidationModuleAllowlist, ValidationModuleCore, ERC2771Module, IERC7943FungibleTransferError |||
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | __CMTAT_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_openzeppelin_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_modules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | approve | Public ❗️ | 🛑  | whenNotPaused |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |
| └ | _authorizePause | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeDeactivate | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeFreeze | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeAllowlistManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _canMintBurnByModule | Internal 🔒 |   | |
| └ | _canMintBurnByModuleAndRevert | Internal 🔒 |   | |
| └ | _canTransact | Internal 🔒 |   | |
| └ | _canTransferStandardByModule | Internal 🔒 |   | |
| └ | _canTransferStandardByModuleAndRevert | Internal 🔒 |   | |
| └ | _checkTransferred | Internal 🔒 | 🛑  | |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
