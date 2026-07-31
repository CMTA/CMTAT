## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol | c05a0233efc4d0ddd0e3278b58c814834547c2c2 |


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
| └ | _callRuleEngineTransferred | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
