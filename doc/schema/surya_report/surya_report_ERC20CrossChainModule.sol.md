## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/ERC20CrossChainModule.sol | 0382436b6ae5192b92b91b07a42f28829267e6dc |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20CrossChainModule** | Implementation | ERC20MintModule, ERC20BurnModule, ERC165Upgradeable, IERC7802, IBurnFromERC20 |||
| └ | crosschainMint | Public ❗️ | 🛑  | onlyTokenBridge |
| └ | crosschainBurn | Public ❗️ | 🛑  | onlyTokenBridge |
| └ | burnFrom | Public ❗️ | 🛑  | onlyBurnerFrom |
| └ | burn | Public ❗️ | 🛑  | onlySelfBurn |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _burnFrom | Internal 🔒 | 🛑  | |
| └ | _burn | Internal 🔒 | 🛑  | |
| └ | _checkTokenBridge | Internal 🔒 | 🛑  | |
| └ | _authorizeBurnFrom | Internal 🔒 | 🛑  | |
| └ | _authorizeSelfBurn | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
