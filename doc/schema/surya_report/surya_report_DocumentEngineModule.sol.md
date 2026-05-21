## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/DocumentEngineModule.sol | a52dc80f2561c58367d49f7194774d2e06ca6c83 |


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
| └ | setDocument | Public ❗️ | 🛑  | onlyDocumentManager |
| └ | removeDocument | Public ❗️ | 🛑  | onlyDocumentManager |
| └ | setDocumentEngine | Public ❗️ | 🛑  | onlyDocumentManager |
| └ | _setDocumentEngine | Internal 🔒 | 🛑  | |
| └ | _authorizeDocumentManagement | Internal 🔒 | 🛑  | |
| └ | _getDocumentEngineModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
