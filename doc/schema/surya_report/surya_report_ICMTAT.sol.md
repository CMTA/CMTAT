## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./interfaces/tokenization/ICMTAT.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ICMTATMint** | Interface |  |||
| └ | mint | External ❗️ | 🛑  |NO❗️ |
||||||
| **ICMTATBurn** | Interface |  |||
| └ | burn | External ❗️ | 🛑  |NO❗️ |
||||||
| **ICMTATPause** | Interface |  |||
| └ | paused | External ❗️ |   |NO❗️ |
| └ | pause | External ❗️ | 🛑  |NO❗️ |
| └ | unpause | External ❗️ | 🛑  |NO❗️ |
| └ | deactivateContract | External ❗️ | 🛑  |NO❗️ |
| └ | deactivated | External ❗️ |   |NO❗️ |
||||||
| **ICMTATEnforcement** | Interface |  |||
| └ | setAddressFrozen | External ❗️ | 🛑  |NO❗️ |
| └ | isFrozen | External ❗️ |   |NO❗️ |
||||||
| **ICMTATBase** | Interface |  |||
| └ | tokenId | External ❗️ |   |NO❗️ |
| └ | terms | External ❗️ |   |NO❗️ |
| └ | setTokenId | External ❗️ | 🛑  |NO❗️ |
| └ | setTerms | External ❗️ | 🛑  |NO❗️ |
||||||
| **ICMTATDebt** | Interface |  |||
| └ | debt | External ❗️ |   |NO❗️ |
| └ | creditEvents | External ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
