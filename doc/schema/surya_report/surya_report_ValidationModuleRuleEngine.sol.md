## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol | 81c68ccc0b558c936e79aca880f811ac85311489 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ValidationModuleRuleEngine** | Implementation | ValidationModuleAllowance, ValidationModuleRuleEngineInternal |||
| └ | setRuleEngine | Public ❗️ | 🛑  | onlyRuleEngineManager |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |
| └ | _canTransfer | Internal 🔒 |   | |
| └ | _canTransferFrom | Internal 🔒 |   | |
| └ | _canTransferFromWithRuleEngine | Internal 🔒 |   | |
| └ | _canTransferWithRuleEngine | Internal 🔒 |   | |
| └ | _authorizeRuleEngineManagement | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
