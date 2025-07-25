## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/3_CMTATBaseERC20CrossChain.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseERC20CrossChain** | Implementation | CMTATBaseERC1404, IERC7802, IBurnFromERC20 |||
| └ | crosschainMint | Public ❗️ | 🛑  | whenNotPaused onlyTokenBridge |
| └ | crosschainBurn | Public ❗️ | 🛑  | whenNotPaused onlyTokenBridge |
| └ | burnFrom | Public ❗️ | 🛑  | onlyRole whenNotPaused |
| └ | burn | Public ❗️ | 🛑  | onlyRole whenNotPaused |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _burnFrom | Internal 🔒 | 🛑  | |
| └ | _checkTokenBridge | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
