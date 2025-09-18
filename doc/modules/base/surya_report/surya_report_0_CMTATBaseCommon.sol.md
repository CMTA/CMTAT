## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/0_CMTATBaseCommon.sol | 07c0f430a12b113d1a6ead1e9a4918e10a105662 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseCommon** | Implementation | VersionModule, ERC20MintModule, ERC20BurnModule, ERC20BaseModule, SnapshotEngineModule, ERC20EnforcementModule, DocumentEngineModule, ExtraInformationModule, AccessControlModule, IBurnMintERC20, IERC5679 |||
| └ | __CMTAT_commonModules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | burnAndMint | Public ❗️ | 🛑  |NO❗️ |
| └ | _checkTransferred | Internal 🔒 | 🛑  | |
| └ | _update | Internal 🔒 | 🛑  | |
| └ | _mintOverride | Internal 🔒 | 🛑  | |
| └ | _burnOverride | Internal 🔒 | 🛑  | |
| └ | _minterTransferOverride | Internal 🔒 | 🛑  | |
| └ | _authorizeERC20AttributeManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeMint | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeBurn | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeDocumentManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeExtraInfoManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeERC20Enforcer | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeForcedTransfer | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeSnapshots | Internal 🔒 | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
