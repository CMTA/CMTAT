## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/DocumentEngineModule.sol | a96b453eb169a3ac7cd0f614bfb17dfb8eb7fbbe |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DocumentEngineModule** | Implementation | Initializable, IDocumentEngineModule |||
| └ | __DocumentEngineModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | documentEngine | Public ❗️ |   |NO❗️ |
| └ | getDocument | Public ❗️ |   |NO❗️ |
| └ | getAllDocuments | Public ❗️ |   |NO❗️ |
| └ | setDocumentEngine | Public ❗️ | 🛑  | onlyDocumentManager |
| └ | _setDocumentEngine | Internal 🔒 | 🛑  | |
| └ | _authorizeDocumentManagement | Internal 🔒 | 🛑  | |
| └ | _getDocumentEngineModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
