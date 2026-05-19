## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/0_CMTATBaseGeneric.sol | 2db1ecb2c69ee4f60e17917ff565907e44da1daf |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CMTATBaseGeneric** | Implementation | Initializable, ContextUpgradeable, ValidationModule, VersionModule, DocumentERC1643Module, ExtraInformationModule, AccessControlModule |||
| └ | __CMTAT_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_openzeppelin_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __CMTAT_modules_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | _authorizeDocumentManagement | Internal 🔒 | 🛑  | onlyRole |
| └ | _authorizeExtraInfoManagement | Internal 🔒 | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
