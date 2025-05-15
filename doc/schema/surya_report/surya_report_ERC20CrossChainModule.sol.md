## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/ERC20CrossChainModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20CrossChainModule** | Implementation | CMTATBase, IERC7802, IBurnFromERC20 |||
| └ | crosschainMint | External ❗️ | 🛑  | onlyRole whenNotPaused |
| └ | crosschainBurn | External ❗️ | 🛑  | onlyRole whenNotPaused |
| └ | burnFrom | Public ❗️ | 🛑  | onlyRole whenNotPaused |
| └ | burn | Public ❗️ | 🛑  | onlyRole whenNotPaused |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _burnFrom | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
