## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/controllers/ValidationModule.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModule** | Implementation | ValidationModuleInternal, PauseModule, EnforcementModule, IERC1404Wrapper |||
| └ | __ValidationModule_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | setRuleEngine | External ❗️ | 🛑  | onlyRole |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | validateTransfer | Public ❗️ |   |NO❗️ |
| └ | _validateTransferByModule | Internal 🔒 |   | |
| └ | _operateOnTransfer | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
