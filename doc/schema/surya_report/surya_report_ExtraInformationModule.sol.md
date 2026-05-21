## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ExtraInformationModule.sol | b7f6063f1c7bee208cad4f4af3becc2e590aa6af |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ExtraInformationModule** | Implementation | Initializable, ICMTATBase |||
| └ | __ExtraInformationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | setTokenId | Public ❗️ | 🛑  | onlyExtraInfoManager |
| └ | setTerms | Public ❗️ | 🛑  | onlyExtraInfoManager |
| └ | setInformation | Public ❗️ | 🛑  | onlyExtraInfoManager |
| └ | tokenId | Public ❗️ |   |NO❗️ |
| └ | terms | Public ❗️ |   |NO❗️ |
| └ | information | Public ❗️ |   |NO❗️ |
| └ | _setTerms | Internal 🔒 | 🛑  | |
| └ | _setTokenId | Internal 🔒 | 🛑  | |
| └ | _setTerms | Internal 🔒 | 🛑  | |
| └ | _setInformation | Internal 🔒 | 🛑  | |
| └ | _authorizeExtraInfoManagement | Internal 🔒 | 🛑  | |
| └ | _getExtraInformationModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
