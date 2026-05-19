## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/2_CMTATBaseAccessControl.sol | cf934aa8b26c9bdc2aeb336391b3c4098da70c18 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseAccessControl** | Implementation | AccessControlModule, CMTATBaseCommon, CMTATBaseDocument |||
| └ | __CMTAT_commonModules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _authorizeERC20AttributeManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeMint | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeBurn | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeDocumentManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeExtraInfoManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeERC20Enforcer | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeForcedTransfer | Internal 🔒 | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
