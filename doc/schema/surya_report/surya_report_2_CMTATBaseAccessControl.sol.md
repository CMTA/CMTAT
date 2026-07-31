## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/2_CMTATBaseAccessControl.sol | 342ba68721bc4c4642a4c29b8dc7aad79051ab65 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseAccessControl** | Implementation | AccessControlModule, CMTATBaseCommon, CMTATBaseDocument |||
| └ | __CMTAT_commonModules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _authorizeTokenAttributeManagement | Internal 🔒 | 🛑  | onlyRole |
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
