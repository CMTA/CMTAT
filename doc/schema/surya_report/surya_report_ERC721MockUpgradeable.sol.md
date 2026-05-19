## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/ERC721MockUpgradeable.sol | d83ab7d6f2e934f059007b1e4e5a462e139a0ac7 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC721MockUpgradeable** | Implementation | ERC721Upgradeable, CMTATBaseGeneric |||
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | mint | Public ❗️ | 🛑  |NO❗️ |
| └ | burn | External ❗️ | 🛑  |NO❗️ |
| └ | safeTransferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _authorizePause | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeDeactivate | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeFreeze | Internal 🔒 | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
