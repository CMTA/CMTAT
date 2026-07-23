## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/DocumentERC1643Module.sol | 2de2e9da4f8be54bc9615462315116478b1c3066 |


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
