## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/options/ERC20EnforcementERC7551Module.sol | 8cb73e41161a89d4d8d4e95547ac9fce6c84cbaa |


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
