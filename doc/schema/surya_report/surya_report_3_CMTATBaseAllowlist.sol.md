## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/3_CMTATBaseAllowlist.sol | 517b746b223a533ad42e9dad2a49520c1fd14d1f |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseAllowlist** | Implementation | Initializable, ContextUpgradeable, CMTATBaseAccessControl, ValidationModuleAllowlist, ValidationModuleAllowance, ERC2771Module, ERC20EnforcementERC7551Module, IERC7943FungibleTransferError |||
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | __CMTAT_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_openzeppelin_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_modules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | approve | Public ❗️ | 🛑  | whenNotPaused |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |
| └ | _authorizePause | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeDeactivate | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeFreeze | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeAllowlistManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeERC20Enforcer | Internal 🔒 | 🛑  | |
| └ | _authorizeForcedTransfer | Internal 🔒 | 🛑  | |
| └ | _canMintBurnByModule | Internal 🔒 |   | |
| └ | _canMintByModuleAndRevert | Internal 🔒 |   | |
| └ | _canBurnByModuleAndRevert | Internal 🔒 |   | |
| └ | _canSend | Internal 🔒 |   | |
| └ | _canReceive | Internal 🔒 |   | |
| └ | _canTransferStandardByModule | Internal 🔒 |   | |
| └ | _canTransferStandardByModuleAndRevert | Internal 🔒 |   | |
| └ | _checkTransferred | Internal 🔒 | 🛑  | |
| └ | getFrozenTokens | Public ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
