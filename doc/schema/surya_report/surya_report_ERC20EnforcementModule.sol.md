## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ERC20EnforcementModule.sol | b59b50648f072b929cce35ec8fc5695fb919e4c6 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20EnforcementModule** | Implementation | ERC20EnforcementModuleInternal, IERC7551ERC20Enforcement, IERC3643ERC20Enforcement |||
| └ | getFrozenTokens | Public ❗️ |   |NO❗️ |
| └ | getActiveBalanceOf | Public ❗️ |   |NO❗️ |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyForcedTransferManager |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyForcedTransferManager |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | _authorizeERC20Enforcer | Internal 🔒 | 🛑  | |
| └ | _authorizeForcedTransfer | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
