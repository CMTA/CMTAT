## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/ERC20CrossChain.sol | c160ebacf784bba03ff79854c4a897198783f18b |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20CrossChain** | Implementation | ERC20MintModule, ERC20BurnModule, ERC165Upgradeable, IERC7802, IBurnFromERC20 |||
| └ | crosschainMint | Public ❗️ | 🛑  | onlyTokenBridge |
| └ | crosschainBurn | Public ❗️ | 🛑  | onlyTokenBridge |
| └ | burnFrom | Public ❗️ | 🛑  | onlyBurnerFrom |
| └ | burn | Public ❗️ | 🛑  | onlyBurnerFrom |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _burnFrom | Internal 🔒 | 🛑  | |
| └ | _checkTokenBridge | Internal 🔒 | 🛑  | |
| └ | _authorizeBurnFrom | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
