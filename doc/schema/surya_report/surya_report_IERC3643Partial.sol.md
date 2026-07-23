## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./interfaces/tokenization/IERC3643Partial.sol | 8358c87ebcdb71cb6a72b342e796ca0a930101f6 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **IERC3643Pause** | Interface |  |||
| └ | paused | External ❗️ |   |NO❗️ |
| └ | pause | External ❗️ | 🛑  |NO❗️ |
| └ | unpause | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC3643ERC20Base** | Interface |  |||
| └ | setName | External ❗️ | 🛑  |NO❗️ |
| └ | setSymbol | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC3643BatchTransfer** | Interface |  |||
| └ | batchTransfer | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC3643Version** | Interface |  |||
| └ | version | External ❗️ |   |NO❗️ |
||||||
| **IERC3643EnforcementEvent** | Interface |  |||
||||||
| **IERC3643Enforcement** | Interface |  |||
| └ | isFrozen | External ❗️ |   |NO❗️ |
| └ | setAddressFrozen | External ❗️ | 🛑  |NO❗️ |
| └ | batchSetAddressFrozen | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC3643ERC20Enforcement** | Interface | IERC7943FungibleEnforcement |||
| └ | freezePartialTokens | External ❗️ | 🛑  |NO❗️ |
| └ | unfreezePartialTokens | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC3643Mint** | Interface |  |||
| └ | mint | External ❗️ | 🛑  |NO❗️ |
| └ | batchMint | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC3643Burn** | Interface |  |||
| └ | burn | External ❗️ | 🛑  |NO❗️ |
| └ | batchBurn | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC3643ComplianceRead** | Interface |  |||
| └ | canTransfer | External ❗️ |   |NO❗️ |
||||||
| **IERC3643IComplianceContract** | Interface |  |||
| └ | transferred | External ❗️ | 🛑  |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
