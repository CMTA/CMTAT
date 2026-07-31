## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./interfaces/tokenization/draft-IERC7551.sol | 37fb7ee2c0c49fd86ef9ecec500aedc65366e490 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **IERC7551Mint** | Interface | IERC5679Mint |||
||||||
| **IERC7551Burn** | Interface | IERC5679Burn |||
||||||
| **IERC7551Pause** | Interface |  |||
| └ | paused | External ❗️ |   |NO❗️ |
| └ | pause | External ❗️ | 🛑  |NO❗️ |
| └ | unpause | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC7551ERC20EnforcementEvent** | Interface |  |||
||||||
| **IERC7551ERC20EnforcementTokenFrozenEvent** | Interface |  |||
||||||
| **IERC7551ERC20Enforcement** | Interface |  |||
| └ | getActiveBalanceOf | External ❗️ |   |NO❗️ |
| └ | getFrozenTokens | External ❗️ |   |NO❗️ |
| └ | freezePartialTokens | External ❗️ | 🛑  |NO❗️ |
| └ | unfreezePartialTokens | External ❗️ | 🛑  |NO❗️ |
| └ | forcedTransfer | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC7551Compliance** | Interface | IERC3643ComplianceRead |||
| └ | canTransferFrom | External ❗️ |   |NO❗️ |
||||||
| **IERC7551Document** | Interface |  |||
| └ | termsHash | External ❗️ |   |NO❗️ |
| └ | setTerms | External ❗️ | 🛑  |NO❗️ |
| └ | metaData | External ❗️ |   |NO❗️ |
| └ | setMetaData | External ❗️ | 🛑  |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
