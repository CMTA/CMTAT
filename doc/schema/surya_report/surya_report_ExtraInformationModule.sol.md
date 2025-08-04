## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ExtraInformationModule.sol | ef80557fafadc88f805837343818611e1dc5a600 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ExtraInformationModule** | Implementation | AccessControlUpgradeable, ICMTATBase |||
| └ | __ExtraInformationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | setTokenId | Public ❗️ | 🛑  | onlyRole |
| └ | setTerms | Public ❗️ | 🛑  | onlyRole |
| └ | setInformation | Public ❗️ | 🛑  | onlyRole |
| └ | tokenId | Public ❗️ |   |NO❗️ |
| └ | terms | Public ❗️ |   |NO❗️ |
| └ | information | Public ❗️ |   |NO❗️ |
| └ | _setTerms | Internal 🔒 | 🛑  | |
| └ | _setTokenId | Internal 🔒 | 🛑  | |
| └ | _setTerms | Internal 🔒 | 🛑  | |
| └ | _setInformation | Internal 🔒 | 🛑  | |
| └ | _getExtraInformationModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
