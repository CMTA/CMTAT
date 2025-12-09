## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/3_CMTATBaseERC20CrossChain.sol | 7d21beb134346630d07186c7ebb7672af11df4e9 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseERC20CrossChain** | Implementation | ERC20CrossChainModule, CCIPModule, CMTATBaseERC1404 |||
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | _mintOverride | Internal 🔒 | 🛑  | |
| └ | _burnOverride | Internal 🔒 | 🛑  | |
| └ | _minterTransferOverride | Internal 🔒 | 🛑  | |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _authorizeCCIPSetAdmin | Internal 🔒 | 🛑  | onlyRole |
| └ | _checkTokenBridge | Internal 🔒 | 🛑  | whenNotPaused |
| └ | _authorizeBurnFrom | Internal 🔒 | 🛑  | onlyRole whenNotPaused |
| └ | _update | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
