## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/DocumentERC1643Module.sol | f8675c688868cd9bdfc0246b3a6e7f310e8e43df |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **DocumentERC1643Module** | Implementation | Initializable, IERC1643 |||
| └ | getDocument | Public ❗️ |   |NO❗️ |
| └ | getAllDocuments | Public ❗️ |   |NO❗️ |
| └ | setDocument | Public ❗️ | 🛑  | onlyDocumentManager |
| └ | removeDocument | Public ❗️ | 🛑  | onlyDocumentManager |
| └ | _authorizeDocumentManagement | Internal 🔒 | 🛑  | |
| └ | _getDocumentERC1643ModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
