## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/controllers/ValidationModule.sol | b5066172e0053da26db7aa93b04ffa09fa40feec |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModule** | Implementation | PauseModule, EnforcementModule, IERC7943TransactError, IERC7943FungibleTransactCheck |||
| └ | canTransact | Public ❗️ |   |NO❗️ |
| └ | _canTransferGenericByModule | Internal 🔒 |   | |
| └ | _canTransferGenericByModuleAndRevert | Internal 🔒 |   | |
| └ | _canMintBurnByModule | Internal 🔒 |   | |
| └ | _canMintBurnByModuleAndRevert | Internal 🔒 |   | |
| └ | _canTransferisFrozen | Internal 🔒 |   | |
| └ | _canTransferisFrozenAndRevert | Internal 🔒 |   | |
| └ | _canTransferStandardByModule | Internal 🔒 |   | |
| └ | _canTransferStandardByModuleAndRevert | Internal 🔒 |   | |
| └ | _canTransact | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
