## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/CMTATBaseWhitelist.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseWhitelist** | Implementation | Initializable, ContextUpgradeable, CMTATBaseCommon, ValidationModuleWhitelist, ValidationModuleCore |||
| └ | _checkTransferred | Internal 🔒 | 🛑  | |
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | __CMTAT_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_openzeppelin_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_internal_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_modules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | _canMintBurnByModule | Internal 🔒 |   | |
| └ | _canTransferGenericByModule | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
