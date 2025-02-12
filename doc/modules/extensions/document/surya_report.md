## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/DocumentEngineModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DocumentModule** | Implementation | AuthorizationModule, IERC1643 |||
| └ | __DocumentModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | documentEngine | Public ❗️ |   |NO❗️ |
| └ | getDocument | Public ❗️ |   |NO❗️ |
| └ | getAllDocuments | Public ❗️ |   |NO❗️ |
| └ | setDocumentEngine | External ❗️ | 🛑  | onlyRole |
| └ | _setDocumentEngine | Internal 🔒 | 🛑  | |
| └ | _getDocumentModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
