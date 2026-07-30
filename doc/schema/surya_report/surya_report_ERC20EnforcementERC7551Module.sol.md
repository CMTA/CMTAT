## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/ERC20EnforcementERC7551Module.sol | 24ba941cb5612435aaf0a4ed48031f603c40130e |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20EnforcementERC7551Module** | Implementation | ERC20EnforcementModule, IERC7551ERC20Enforcement |||
| └ | getFrozenTokens | Public ❗️ |   |NO❗️ |
| └ | getActiveBalanceOf | Public ❗️ |   |NO❗️ |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyForcedTransferManager |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
