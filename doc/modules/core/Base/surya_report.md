## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/BaseModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **BaseModule** | Implementation | AuthorizationModule |||
| └ | __Base_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | tokenId | Public ❗️ |   |NO❗️ |
| └ | terms | Public ❗️ |   |NO❗️ |
| └ | information | Public ❗️ |   |NO❗️ |
| └ | setTokenId | Public ❗️ | 🛑  | onlyRole |
| └ | setTerms | Public ❗️ | 🛑  | onlyRole |
| └ | setInformation | Public ❗️ | 🛑  | onlyRole |
| └ | _setTokenId | Internal 🔒 | 🛑  | |
| └ | _setTerms | Internal 🔒 | 🛑  | |
| └ | _setInformation | Internal 🔒 | 🛑  | |
| └ | _getBaseModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
