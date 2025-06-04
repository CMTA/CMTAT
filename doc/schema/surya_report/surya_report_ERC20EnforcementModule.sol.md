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
| **ERC20EnforcementModule** | Implementation | ERC20Upgradeable, IERC7551ERC20Enforcement, IERC3643ERC20Enforcement, IERC7551ERC20EnforcementEvent, AuthorizationModule |||
| └ | getFrozenTokens | Public ❗️ |   |NO❗️ |
| └ | getActiveBalanceOf | Public ❗️ |   |NO❗️ |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyRole |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyRole |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyRole |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyRole |
| └ | _freezePartialTokens | Internal 🔒 | 🛑  | |
| └ | _unfreezePartialTokens | Internal 🔒 | 🛑  | |
| └ | _unfreezeTokens | Internal 🔒 | 🛑  | |
| └ | _forcedTransfer | Internal 🔒 | 🛑  | |
| └ | _checkActiveBalance | Internal 🔒 |   | |
| └ | _getEnforcementModuleStorage | Private 🔐 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
