## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/controllers/ValidationModule.sol | 0c4a5e8f583d5d9eaa6785621f647e14d785af81 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModule** | Implementation | PauseModule, EnforcementModule, IERC7943FungibleSendReceiveError, IERC7943FungibleSendReceiveCheck |||
| └ | canSend | Public ❗️ |   |NO❗️ |
| └ | canReceive | Public ❗️ |   |NO❗️ |
| └ | _canTransferGenericByModule | Internal 🔒 |   | |
| └ | _canTransferGenericByModuleAndRevert | Internal 🔒 |   | |
| └ | _canMintBurnByModule | Internal 🔒 |   | |
| └ | _canMintByModuleAndRevert | Internal 🔒 |   | |
| └ | _canBurnByModuleAndRevert | Internal 🔒 |   | |
| └ | _canTransferisFrozen | Internal 🔒 |   | |
| └ | _canTransferisFrozenAndRevert | Internal 🔒 |   | |
| └ | _canTransferStandardByModule | Internal 🔒 |   | |
| └ | _canTransferStandardByModuleAndRevert | Internal 🔒 |   | |
| └ | _canSend | Internal 🔒 |   | |
| └ | _canReceive | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
