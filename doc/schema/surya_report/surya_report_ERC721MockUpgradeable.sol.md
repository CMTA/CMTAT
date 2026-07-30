## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/ERC721MockUpgradeable.sol | 2c79ed9fd517cbb4b0b426ad7c0d19efa573d45c |


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
