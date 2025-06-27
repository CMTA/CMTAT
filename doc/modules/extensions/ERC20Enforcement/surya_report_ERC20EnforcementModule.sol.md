## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ERC20EnforcementModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20EnforcementModule** | Implementation | ERC20EnforcementModuleInternal, AccessControlUpgradeable, IERC7551ERC20Enforcement, IERC3643ERC20Enforcement |||
| └ | getFrozenTokens | Public ❗️ |   |NO❗️ |
| └ | getActiveBalanceOf | Public ❗️ |   |NO❗️ |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyRole |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyRole |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyRole |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
