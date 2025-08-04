## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/0_CMTATBaseCommon.sol | 8f9784520587e0b3e91d67824fe820ec8a71c6d6 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseCommon** | Implementation | BaseModule, ERC20MintModule, ERC20BurnModule, ERC20BaseModule, SnapshotEngineModule, ERC20EnforcementModule, DocumentEngineModule, ExtraInformationModule, AccessControlModule, IBurnMintERC20 |||
| └ | __CMTAT_commonModules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | burnAndMint | Public ❗️ | 🛑  |NO❗️ |
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | _checkTransferred | Internal 🔒 | 🛑  | |
| └ | _update | Internal 🔒 | 🛑  | |
| └ | _mintOverride | Internal 🔒 | 🛑  | |
| └ | _burnOverride | Internal 🔒 | 🛑  | |
| └ | _minterTransferOverride | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
