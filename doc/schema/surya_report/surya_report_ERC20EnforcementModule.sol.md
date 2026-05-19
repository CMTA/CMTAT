## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ERC20EnforcementModule.sol | 289591feebe8af7feae0d3382c4e6af23aa951a7 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC20EnforcementModule** | Implementation | ERC20EnforcementModuleInternal, IERC3643ERC20Enforcement, IERC7943FungibleEnforcementSpecific |||
| └ | getFrozenTokens | Public ❗️ |   |NO❗️ |
| └ | forcedTransfer | Public ❗️ | 🛑  | onlyForcedTransferManager |
| └ | freezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | unfreezePartialTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | setFrozenTokens | Public ❗️ | 🛑  | onlyERC20Enforcer |
| └ | _freezeTokensEmitEvents | Internal 🔒 | 🛑  | |
| └ | _unfreezeTokensEmitEvents | Internal 🔒 | 🛑  | |
| └ | _authorizeERC20Enforcer | Internal 🔒 | 🛑  | |
| └ | _authorizeForcedTransfer | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
