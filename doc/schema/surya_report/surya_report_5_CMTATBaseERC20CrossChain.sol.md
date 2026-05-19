## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/5_CMTATBaseERC20CrossChain.sol | 39f9dc24c67539fa7f9eafbd6d2bdbc639ef1fb2 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseERC20CrossChain** | Implementation | ERC20CrossChainModule, CCIPModule, CMTATBaseERC1404 |||
| └ | crosschainBurn | Public ❗️ | 🛑  | onlyTokenBridge |
| └ | approve | Public ❗️ | 🛑  |NO❗️ |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _mintOverride | Internal 🔒 | 🛑  | |
| └ | _burnOverride | Internal 🔒 | 🛑  | |
| └ | _burn | Internal 🔒 | 🛑  | |
| └ | _minterTransferOverride | Internal 🔒 | 🛑  | |
| └ | _authorizeCCIPSetAdmin | Internal 🔒 | 🛑  | onlyRole |
| └ | _checkTokenBridge | Internal 🔒 | 🛑  | whenNotPaused |
| └ | _authorizeBurnFrom | Internal 🔒 | 🛑  | onlyRole whenNotPaused |
| └ | _authorizeSelfBurn | Internal 🔒 | 🛑  | onlyRole whenNotPaused |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
