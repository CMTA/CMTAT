## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ExtraInformationModule.sol | 1bec65f02717454936f5ae4adb0c107ff92ce07d |


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
