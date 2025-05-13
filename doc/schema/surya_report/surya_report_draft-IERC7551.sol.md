## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./interfaces/tokenization/draft-IERC7551.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **IERC7551Mint** | Interface |  |||
| └ | mint | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC7551Burn** | Interface |  |||
| └ | burn | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC7551Pause** | Interface |  |||
| └ | paused | External ❗️ |   |NO❗️ |
| └ | pause | External ❗️ | 🛑  |NO❗️ |
| └ | unpause | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC7551ERC20Enforcement** | Interface |  |||
| └ | getActiveBalanceOf | External ❗️ |   |NO❗️ |
| └ | getFrozenTokens | External ❗️ |   |NO❗️ |
| └ | freezePartialTokens | External ❗️ | 🛑  |NO❗️ |
| └ | unfreezePartialTokens | External ❗️ | 🛑  |NO❗️ |
| └ | forcedTransfer | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC7551Compliance** | Interface |  |||
| └ | canTransfer | External ❗️ |   |NO❗️ |
| └ | canTransferFrom | External ❗️ |   |NO❗️ |
||||||
| **IERC7551Base** | Interface |  |||
| └ | metaData | External ❗️ |   |NO❗️ |
| └ | setMetaData | External ❗️ | 🛑  |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
