## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/core/ERC20MintModule.sol | c9b01932ec4ecb147f0e2ac00324480e9a40a23b |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20MintModule** | Implementation | ERC20MintModuleInternal, IERC3643Mint, IERC3643BatchTransfer, IERC7551Mint, IMintBatchERC20Event |||
| └ | mint | Public ❗️ | 🛑  | onlyMinter |
| └ | mint | Public ❗️ | 🛑  | onlyMinter |
| └ | batchMint | Public ❗️ | 🛑  | onlyMinter |
| └ | batchTransfer | Public ❗️ | 🛑  | onlyMinter |
| └ | _mint | Internal 🔒 | 🛑  | |
| └ | _authorizeMint | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
