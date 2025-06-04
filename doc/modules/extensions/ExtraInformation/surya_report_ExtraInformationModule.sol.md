## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ExtraInformationModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ExtraInformationModule** | Implementation | IERC7551Base, ICMTATBase, AuthorizationModule |||
| └ | __ExtraInformationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | tokenId | Public ❗️ |   |NO❗️ |
| └ | terms | Public ❗️ |   |NO❗️ |
| └ | information | Public ❗️ |   |NO❗️ |
| └ | metaData | Public ❗️ |   |NO❗️ |
| └ | setTokenId | Public ❗️ | 🛑  | onlyRole |
| └ | setTerms | Public ❗️ | 🛑  | onlyRole |
| └ | setInformation | Public ❗️ | 🛑  | onlyRole |
| └ | setMetaData | Public ❗️ | 🛑  | onlyRole |
| └ | _setMetaData | Internal 🔒 | 🛑  | |
| └ | _setTokenId | Internal 🔒 | 🛑  | |
| └ | _setTerms | Internal 🔒 | 🛑  | |
| └ | _setInformation | Internal 🔒 | 🛑  | |
| └ | _getExtraInformationModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
