

# CMTA Token 

> To use the CMTAT, we recommend the latest audited version, from the [Releases](https://github.com/CMTA/CMTAT/releases) page. Currently, it is the version [v2.3.0](https://github.com/CMTA/CMTAT/releases/tag/v2.3.0)

[TOC]



## Introduction

The CMTA token (CMTAT) is a security token framework that includes various compliance features such as conditional transfer, account freeze, and token pause. CMTAT was initially optimized for the Swiss law framework, but can be suitable for other jurisdictions. This repository provides CMTA's reference Solidity implementation of CMTAT, suitable for EVM chains such as Ethereum.

The CMTAT is an open standard from the [Capital Markets and Technology Association](http://www.cmta.ch/) (CMTA), which gathers Swiss finance, legal, and technology organizations.
The CMTAT was developed by a working group of CMTA's Technical Committee that includes members from Atpar, Bitcoin Suisse, Blockchain Innovation Group, Hypothekarbank Lenzburg, Lenz & Staehelin, Metaco, Mt Pelerin, SEBA, Swissquote, Sygnum, Taurus and Tezos Foundation. The design and security of the CMTAT was supported by ABDK, a leading team in smart contract security.

The preferred way to receive comments is through the GitHub issue tracker.  Private comments and questions can be sent to the CMTA secretariat at <a href="mailto:admin@cmta.ch">admin@cmta.ch</a>. For security matters, please see [SECURITY.md](./SECURITY.md).

Note that CMTAT may be used in other jurisdictions than Switzerland, and for tokenizing various asset types, beyond equity and debt products. 

### Overview

The CMTAT supports the following core features:

* Basic mint, burn, and transfer operations
* Pause of the contract and freeze of specific accounts

Furthermore, the present implementation uses standard mechanisms in
order to support:

* Upgradeability, via deployment of the token with a proxy
* "Gasless" transactions
* Conditional transfers, via a rule engine

This reference implementation allows the issuance and management of tokens representing equity securities.
It can however also be used for other forms of financial instruments such as debt securities.

You may modify the token code by adding, removing, or modifying features. However, the core modules must remain in place for compliance with CMTA specification.

## Standard ERC

Here the list of ERC used by CMTAT v3.0.0



### Schema

![architecture-ERC.drawio](./doc/schema/drawio/architecture-ERC.drawio.png)



### CMTAT version support

Here the list of ERC supported between different version:

|                                                              | ERC status               | CMTAT 1.0 | CMTAT 2.30 | CMTAT 3.0.0                                                  |           |          |          |
| ------------------------------------------------------------ | ------------------------ | --------- | ---------- | ------------------------------------------------------------ | --------- | -------- | -------- |
| Deployment version                                           |                          |           |            | (Standalone & Proxy)                                         | Light     | UUPS     | ERC1363  |
| **Fungible tokens**                                          |                          |           |            |                                                              |           |          |          |
| [ERC-20](https://eips.ethereum.org/EIPS/eip-20)              | Standard Track (final)   | &#x2611;  | &#x2611;   | &#x2611;                                                     | &#x2611;  | &#x2611; | &#x2611; |
| [ERC-1363](https://eips.ethereum.org/EIPS/eip-1363)          | Standard Track (final)   | &#x2612;  | &#x2612;   | &#x2612;                                                     | &#x2612;  | &#x2612; | &#x2611; |
| **Tokenization**                                             |                          |           |            |                                                              |           |          |          |
| [ERC-1404](https://github.com/ethereum/eips/issues/1404)<br />(Simple Restricted Token Standard) | Draft                    | &#x2611;  | &#x2611;   | &#x2611;                                                     | &#x2612;  | &#x2611; | &#x2611; |
| [ERC-1643](https://github.com/ethereum/eips/issues/1643) (Document Management Standard) <br />(Standard from [ERC-1400](https://github.com/ethereum/EIPs/issues/1411))<br />(Slightly improved) | Draft                    | &#x2612;  | &#x2612;   | &#x2611;<br />(through DocumentEngine with small improvement) | &#x2612;  | &#x2611; | &#x2611; |
| [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643)<br /><br />(Without on-chain identity) | Standard Track (final)   | &#x2612;  | &#x2612;   | &#x2611;                                                     | &#x2612;  | &#x2611; | &#x2611; |
| [ERC-7551](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg/16416)<br />(Slightly improved) | Draft                    | &#x2612;  | &#x2612;   | &#x2611;<br />                                               | Partially | &#x2611; | &#x2611; |
| **Proxy support related**                                    |                          |           |            |                                                              |           |          |          |
| Deployment with a UUPS proxy ([ERC-1822](https://eips.ethereum.org/EIPS/eip-1822)) | Stagnant<br />(but used) | &#x2612;  | &#x2612;   | &#x2612;                                                     | &#x2612;  | &#x2611; | &#x2612; |
| [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201)<br/>(Storage namespaces for proxy contract) | Standard Track (final)   | &#x2612;  | &#x2612;   | &#x2611;                                                     | &#x2611;  | &#x2611; | &#x2611; |
| **Technical**                                                |                          |           |            |                                                              |           |          |          |
| [ERC-2771](https://eips.ethereum.org/EIPS/eip-2771) (Meta Tx / gasless) | Standard Track (final)   | &#x2611;  | &#x2611;   | &#x2611;                                                     | &#x2612;  | &#x2611; | &#x2611; |
| [ERC-6093](https://eips.ethereum.org/EIPS/eip-6093) (Custom errors for ERC-20 tokens) | Standard Track (final)   | &#x2612;  | &#x2612;   | &#x2611;<br />                                               | &#x2611;  | &#x2611; | &#x2611; |
| [ERC-7802](https://eips.ethereum.org/EIPS/eip-7802) (cross-chain token/transfers) | Draft                    | &#x2612;  | &#x2612;   | &#x2611;<br />                                               | &#x2612;  | &#x2612; | &#x2612; |

### Details

#### ERC-3643

> [ERC specification](https://eips.ethereum.org/EIPS/eip-3643)
> Status: Standards Track

The [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) is an official Ethereum standard, unlike ERC-1400 and ERC-1404. This standard, also built on top of ERC-20, offers a way to manage and perform compliant transfers of security tokens.

ERC-3643 enforces identity management as a core component of the standards by using a decentralized identity system called [onchainid](https://www.onchainid.com/).

While CMTAT does not include directly the identity management system, it shares with ERC-3643 several same functions. The interface is available in [IERC3643Partial.sol](./contracts/interfaces/tokenization/IERC3643Partial.sol)

To represent the level of similarity between ERC-3643 interface and CMTAT functionnalities, we have created three levels of conformity.

If you want to use CMTAT to create a version implementing all functions from ERC-3643, you can create it through a dedicated deployment version (like what has been done for UUPS and ERC-1363).

The implemented interface is available in [IERC3643Partial](./contracts/interfaces/tokenization/IERC3643Partial.sol)

The main reason the argument names change is because CMTAT relies on OpenZeppelin to name the arguments

##### Pause

Module: PauseModule

| **ERC-3643**                             | **CMTAT 3.0.**0                   |          |          |          |          |
| :--------------------------------------- | :-------------------------------- | -------- | -------- | -------- | -------- |
| Deployment version                       |                                   | Full     | Light    | UUPS     | ERC1363  |
| `pause() external`                       | Same                              | &#x2611; | &#x2611; | &#x2611; | &#x2611; |
| `unpause() external`                     | Same                              | &#x2611; | &#x2611; | &#x2611; | &#x2611; |
| `paused() external view returns (bool);` | Same                              | &#x2611; | &#x2611; | &#x2611; | &#x2611; |
| `  event Paused(address _userAddress);`  | `event Paused(address account)`   | &#x2611; | &#x2611; | &#x2611; | &#x2611; |
| ` event Unpaused(address _userAddress);` | `event Unpaused(address account)` | &#x2611; | &#x2611; | &#x2611; | &#x2611; |

##### ERC20Base

| **ERC-3643**                                  | **CMTAT 3.0**                        | All deployment version |
| :-------------------------------------------- | :----------------------------------- | ---------------------- |
| `setName(string calldata _name) external;`    | `setName(string calldata name_)`     | &#x2611;<br />         |
| `setSymbol(string calldata _symbol) external` | `setSymbol(string calldata symbol_)` | &#x2611;<br />         |

##### Supply Management (burn/mint)

| **ERC-3643**                                                 | **CMTAT 3.0 Modules** | **CMTAT 3.0 Functions**                                      | Deployment version |
| :----------------------------------------------------------- | :-------------------- | :----------------------------------------------------------- | ------------------ |
| `  batchMint(address[] calldata _toList, uint256[] calldata _amounts) external;` | ERC20MintModule       | `mint(address account, uint256 value)`                       | All                |
| `  batchMint(address[] calldata _toList, uint256[] calldata _amounts) external;` | ERC20MintModule       | `batchMint(address[] calldata accounts,uint256[] calldata values) ` | All                |
| `function batchTransfer(address[] calldata _toList, uint256[] calldata _amounts) external;` | ERC20MintModule       | `batchTransfer(address[] calldata tos,uint256[] calldata values)` | All                |
| `burn(address _userAddress, uint256 _amount) external`       | ERC20BurnModule       | `function burn(address account,uint256 value)`               | All                |
| `batchBurn(address[] calldata _userAddresses, uint256[] calldata _amounts) external` | ERC20BurnModule       | `batchBurn(address[] calldata accounts,uint256[] calldata values)` | All                |

Warning: `batchTransfer` is restricted to the MINTER_ROLE to avoid the possibility to use non-standard function to move tokens

##### ERC20Enforcement

| **ERC-3643**                                                 | **CMTAT 3.0**                                                | Deployment version       |
| :----------------------------------------------------------- | :----------------------------------------------------------- | ------------------------ |
| ` isFrozen(address _userAddress)`                            | `isFrozen(address account)`                                  | All                      |
| `forcedTransfer(address _from, address _to, uint256 _amount) external returns (bool)` | `forcedTransfer(address from, address to, uint256 value) external returns (bool)` | All except Light version |
| `batchForcedTransfer(address[] calldata _fromList, address[] calldata _toList, uint256[] calldata _amounts) external` | Not implemented                                              | -                        |

##### Validation

Note: `canTransfer` is defined for the compliance contract in ERC-3643.

| **ERC-3643**                                                 | **CMTAT 3.0**                                          | Deployment version |
| :----------------------------------------------------------- | :----------------------------------------------------- | ------------------ |
| `canTransfer(address _from, address _to, uint256 _amount) external view returns (bool)` | `canTransfer(address from, address to, uint256 value)` | All                |

####  ERC-7551 (eWPG)

> [ERC specification](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg/16416)
>
> Status: draft

This section presents a correspondence table between [ERC-7551](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg/16416) and their equivalent functions inside CMTAT.

The ERC-7551 is currently a draft ERC proposed by the Federal Association of Crypto Registrars from Germany to tokenize assets in compliance with [eWPG](https://www.gesetze-im-internet.de/ewpg/). 

The interface is supposed to work on top of additional standards that cover the actual storage of ownership of shares of a security in the form of a token (e.g. ERC-20 or ERC-1155).

##### CMTAT modification

Since it is not yet an official standard, we decided to use the same name and signature as ERC-3643. Typically, we define a function `burn`instead of `destroyTokens`.

The implemented interface is available in [IERC7551](./contracts/interfaces/tokenization/draft-IERC7551.sol)

| **N°** | **Functionalities**                                          | **ERC-7551 Functions**                    | **CMTAT 3.0.0**          | Implementations details                                      | Modules                      |
| :----- | :----------------------------------------------------------- | :---------------------------------------- | :----------------------- | ------------------------------------------------------------ | ---------------------------- |
| 1      | Freeze and unfreeze a specific amount of tokens              | freezeTokens<br />unfreezeTokens          | &#x2611;                 | Same function as ERC-3643 <br />(`setAddressFrozen`)         | EnforcementModule            |
| 2      | Pausing transfers The operator can pause and unpause transfers | pauseTransfers                            | &#x2611;                 | Same function as ERC-3643 (`pause/unpause`)<br /> + `deactivateContract` | PauseModule                  |
| 3      | Link to off-chain document<br />Add the hash of a document   | setPaperContractHash                      | Equivalent functionality | Done with the field terms.<br />This field is represented as a Document also (name, uri, hash, last on-chain modification date) | ExtraInformationModule       |
| 4      | Metadata JSON file                                           | setMetaDataJSON                           | &#x2611;                 | Define function `setMetaData`                                | ExtraInformationModule       |
| 5      | Forced transfersTransfer `amount` tokens to `to` without requiring the consent of `fro`m | forceTransferFrom                         | &#x2611;                 | Same function as ERC-3643<br />`forcedTransfer`              | ERC20EnforcementModule       |
| 6      | Token supply managementreduce the balance of `tokenHolder` by `amount` without increasing the amount of tokens of any other holder | destroyTokens                             | &#x2611;                 | Function burn                                                | BurnModule                   |
| 7      | Token supply managementincrease the balance of `to` by `amount` without decreasing the amount of tokens from any other holder. | issue                                     | &#x2611;                 | Function mint and mintBatch                                  | MintModule                   |
| 8      | Transfer compliance<br />Check if a transfer is valid        | `canTransfer() `and a `canTransferFrom()` | &#x2611;                 | IERC3643Compliance (canTransfer and `canTransfrom)           | ValidationInternalCoreModule |

 

#### ERC-7802 (Crosschain transfers)

>  [ERC specification]( https://eips.ethereum.org/EIPS/eip-7802)
> Status: draft

This standard introduces a minimal and extensible interface, `IERC7802`, for tokens to enable standardized crosschain communication.

CMTAT implements this standard in the option module `ERC20CrossChain`.

This standard is notably used by Optimism to provide cross-chain bridge between Optimism chain, see [docs.optimism.io/interop/superchain-erc20](https://docs.optimism.io/interop/superchain-erc20)

More information here: [Cross-Chain bridge support](doc/general/crosschain-bridge-support.md)

Deployment version: since it is an option module, it is not currently used in the deployment version CMTAT ERC-1363, UUPS and light.



-----

## Architecture

CMTAT architecture is divided in two main components: module and engines

The main schema describing the architecture can be found here: [architecture.pdf](./doc/schema/drawio/architecture.pdf) 



### Base contract

The base contracts are abstract contracts, so not directly deployable, which inherits from several different modules.

Base contracts are used by the different deployable contracts (CMTATStandalone, CMTATUpgradeable,...) to inherits from the different modules

| Name                                                         | Description                                                  | CMTAT Standalone /Upgradeable | CMTAT ERC1363 (Upgradeable & Standalone) | CMTAT Upgradeable UUPS | CMTAT Light (Upgradeadble & Standalone) |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ----------------------------- | ---------------------------------------- | ---------------------- | --------------------------------------- |
| [CMTATBase](./contracts/modules/CMTATBase.sol)               | Inherit from all core and extensions modules                 | &#x2611;                      | &#x2611;                                 | &#x2611;               | &#x2612;                                |
| [CMTATBaseCore](./contracts/modules/CMTATBaseCore.sol)       | Inherit from from all core modules                           | &#x2612;                      | &#x2612;                                 | &#x2612;               | &#x2611;                                |
| [CMTATERC1363Base](./contracts/modules/CMTATERC1363Base.sol) | Inherit from CMTATBase, but also ERC-1363 OpenZeppelin contract and MetaTxModule (ERC-2771) | &#x2612;                      | &#x2611;                                 | &#x2612;               | &#x2612;                                |
| [CMTATBaseOption](./contracts/modules/CMTATBaseOption.sol)   | Inherit from CMTATBase, but also from all other option modules | &#x2611;                      | &#x2612;                                 | &#x2612;               | &#x2612;                                |



#### CMTATBase

![CMTATBase](./doc/schema/uml/CMTATBase.png)



CMTAT Base adds several functions: 

- `burnAndMint`to burn and mint atomically in the same function.

#### CMTAT Base Core

CMTAT Base Core adds several functions: 

- `burnAndMint`to burn and mint atomically in the same function.
- `forceBurn`to allow the admin to burn tokens from a frozen address (defined in EnforcementModule)
  - This function is not required in CMTATBase because the function `forcedTransfer` (ERC20EnforcementModule) can be used instead.

  ![CMTATBaseCore](./doc/schema/uml/CMTATBaseCore.png)



#### CMTAT ERC1363 Base





![surya_inheritance_CMTATERC1363Base.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATERC1363Base.sol.png)





#### CMTAT Base Option

![surya_inheritance_CMTATBaseOption.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATBaseOption.sol.png)

### Module

#### Description

Modules describe a **logical** code separation inside CMTAT.  They are defined as abstract contracts.
Their code and functionalities are part of the CMTAT and therefore are also included in the calculation of the contract size and the maximum size limit of 24 kB.

It is always possible to delete a module, but this requires modifying the code and compiling it again, which require to perform a security audit on these modifications.

Modules are also separated in different categories.

- **Internal** modules: implementation for a module when OpenZeppelin does not provide a library to use. For example, this is the case for the `EnforcementModule`.
- **Options**: modules added to wrapper modules (core & extensions).
- **Wrapper** modules: abstract contract around OpenZeppelin contracts or internal module.
  For example, the wrapper `PauseModule` provides public functions to call the internal functions from OpenZeppelin.
  - Core (Wrapper sub-category): Contains the modules required to be CMTA compliant
  - Extension (Wrapper sub-category): not required to be CMTA compliant, "bonus features" (snapshotModule, debtModule)
  



#### List

Here is the list of modules supported between different versions and the difference.

For simplicity, the module names and function locations are those of version 3.0.0

- "fn" means function
- Changes made in a release are considered maintained in the following release unless explicitly stated otherwise

##### Controllers

| Modules                            | Description                                                  | File                                                         | CMTAT 1.0 | CMTAT 2.30 | CMTAT 3.0.0 | CMTAT 3.0 Light |
| ---------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | --------- | ---------- | ----------- | --------------- |
| ValidationModuleInternalCore<br /> | `canTransfer`and `canTransferFrom`<br />The core module does not implement ERC-1404 and the RuleEngine | [ValidationModuleInternalCore.sol](./contracts/modules/internal//ValidationModuleInternalCore.sol) | &#x2611;  | &#x2611;   | &#x2611;    | &#x2611;        |
| ValidationModuleInternal<br />     | Configure a `RuleEngine`                                     | [ValidationModuleInternal.sol](./contracts/modules/internal/ValidationModuleInternal.sol) | &#x2611;  | &#x2611;   | &#x2611;    | &#x2612;        |
| ValidationModuleERC1404            | Implements ERC-1404                                          | [ValidationModuleERC1404.sol](./contracts/modules/wrapper/controllers/ValidationModuleERC1404.sol) | &#x2611;  | &#x2611;   | &#x2611;    | &#x2612;        |



- ValidationModuleCore

![surya_inheritance_ValidationModuleCore.sol](./doc/schema/surya_inheritance/surya_inheritance_ValidationModuleInternalCore.sol.png)





- ValidationModuleInternal

![surya_inheritance_ValidationModuleInternal.sol](./doc/schema/surya_inheritance/surya_inheritance_ValidationModuleInternal.sol.png)



- ValidationModuleERC1404



![surya_inheritance_ValidationModuleERC1404.sol](./doc/schema/surya_inheritance/surya_inheritance_ValidationModuleERC1404.sol.png)

##### Core modules

Generally, these modules are required to be compliant with the CMTA specification.

| Modules                                                      | Description                    | File                                                         | CMTAT 1.0 | CMTAT 2.30                                                   | CMTAT 3.0.0                                                  |
| ------------------------------------------------------------ | ------------------------------ | ------------------------------------------------------------ | --------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [BaseModule](doc/modules/core/Base/base.md)                  | Contract version               | [BaseModule.sol](./dev/contracts/modules/wrapper/core/BaseModule.sol) | &#x2611;  | &#x2611;<br />(Add two fields: flag and information)         | &#x2611;<br />Remove field flag (not used)<br />Keep only the field VERSION and move the rest (tokenId, information,..) to an extension module `ExtraInformation` |
| [ERC20 Burn](doc/modules/core/ERC20Burn/ERC20Burn.md)<br />(Prev. BurnModule) | Burn functions                 | [ERC20BurnModule.sol](./contracts/modules/wrapper/core/ERC20BurnModule.sol) | &#x2611;  | &#x2611;<br />Replace fn `burnFrom` by fn `forceBurn`        | Add fn `burnBatch`<br />Rename `forceBurn` in `burn`<br />`burnFrom` is moved to the option module `ERC20CrossChain` |
| [Enforcement](doc/modules/core/Enforcement/enforcement.md)   | Freeze/unfreeze address        | [EnforcementModule.sol](./dev/contracts/modules/wrapper/core/EnforcementModule.sol) | &#x2611;  | &#x2611;                                                     | &#x2611;                                                     |
| [ERC20Base](doc/modules/core/ERC20Base/ERC20base.md)         | decimals, set name & symbo     | [ERC20BaseModule.sol](./dev/contracts/modules/wrapper/core/ERC20BaseModule.sol) | &#x2611;  | &#x2611;<br />Remove fn `forceTransfer`<br />(replaced by `burn`and `mint`)<br /> | Add fn `balanceInfo` (useful to distribute dividends)<br />Add  fn `forcedTransfer`<br />Add fn `setName`and `setSymbol`<br />Remove custom fn `approve`(keep only ERC-20 approve) |
| [ERC20 Mint](doc/modules/core/ERC20Mint/ERC20Mint.md)        | Mint functions + BatchTransfer | [ERC20MintModule.sol](./contracts/modules/wrapper/core/ERC20MintModule.sol) | &#x2611;  | &#x2611;                                                     | Add fn `mintBatch`<br />Add fn `transferBatch` <br />        |
| [Pause Module](doc/modules/core/Pause/pause.md)              | Pause and deactivate contract  | [PauseModule.sol](./contracts/modules/wrapper/core/PauseModule.sol) | &#x2611;  | &#x2611;                                                     | Replace fn `kill` by fn `deactivateContract`                 |



  

##### Extensions modules

Generally, these modules are not required to be compliant with the CMTA specification.

| Modules                                                      | Description                                                  | File                                                         | CMTAT 1.0            | CMTAT 2.30                                               | CMTAT 3.0.0                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| [DebtModule](doc/modules/extensions/debt/debt.md)            | Set Debt Info                                                | [DebtModule.sol](./contracts/modules/wrapper/extensions/DebtModule.sol) | &#x2612;             | &#x2611;                                                 | &#x2611;  <br />(Don't include CreditEvents managed by DebtEngineModule) |
| [ExtraInformation](doc/modules/extensions/ExtraInformation/extraInformation.md) | Set extra information (tokenId, terms, metadata)             | [ExtraInformationModule.sol](./contracts/modules/wrapper/extensions/ExtraInformationModule.sol) | &#x2611;(BaseModule) | &#x2611;(BaseModule)                                     | &#x2611;<br />                                               |
| [SnapshotEngineModule](doc/modules/extensions/snapshotEngine/Snapshot.md)<br />(Prev. SnapshotModule) | Set snapshotEngine                                           | [SnapshotEngineModule.sol](./contracts/modules/wrapper/extensions/SnapshotEngineModule.sol) | &#x2611;             | Partial<br />(Not included by default because unaudited) | &#x2611; <br />(require an external SnapshotEngine)          |
| [DocumentEngineModule](doc/modules/extensions/documentEngine/document.md) | Set additional document (ERC1643) through a DocumentEngine   | [DocumentEngineModule.sol](./contracts/modules/wrapper/extensions/DocumentEngineModule.sol) | &#x2612;             | &#x2612;                                                 | &#x2611;                                                     |
| ERC20EnforcementModule                                       | The admin (or a third party appointed by it) can partially freeze a part of the balance of a token holder. | [ERC20EnforcementModule.sol](./contracts/modules/wrapper/extensions/ERC20EnforcementModule.sol) | &#x2612;             | &#x2612;                                                 | &#x2611;                                                     |

##### Options modules

| Modules                                                      | Description                                            | File                                                         | CMTAT 1.0 | CMTAT 2.30                          | CMTAT 3.0.0 |
| ------------------------------------------------------------ | ------------------------------------------------------ | ------------------------------------------------------------ | --------- | ----------------------------------- | ----------- |
| [ERC20CrossChain](doc/modules/options/erc20crosschain/erc20crosschain.md) | Cross-chain functions (ERC-7802)                       | [ERC20CrossChainModule.sol](./contracts/modules/options/ERC20CrossChainModule.sol) | &#x2612;  | &#x2612;                            | &#x2611;    |
| [DebtEngineModule](doc/modules/options/debtEngine/debtEngine.md) | Add a DebtEngine module (requires to set CreditEvents) | [DebtEngineModule.sol](./contracts/modules/options/DebtEngineModule.sol) | &#x2612;  | &#x2612;                            | &#x2611;    |
| [MetaTx](doc/modules/options/metatx/metatx.md)               | ERC-2771 support                                       | [ MetaTxModule.sol](./contracts/modules/wrapper/extensions/MetaTxModule.sol) | &#x2611;  | &#x2611;<br />(forwarder immutable) | &#x2611;    |



##### Security

|                                                              | Description    | File                                                         | CMTAT 1.0 | CMTAT 2.30                                         | CMTAT 3.0.0 |
| ------------------------------------------------------------ | -------------- | ------------------------------------------------------------ | --------- | -------------------------------------------------- | ----------- |
| [AuthorizationModule](doc/modules/security/authorization.md) | Access Control | [AuthorizationModule.sol](./contracts/modules/security/AuthorizationModule.sol) | &#x2611;  | &#x2611;<br />(Admin has all the roles by default) | &#x2611;    |



### Access Control (RBAC)

CMTAT uses a RBAC access control by using the contract `AccessControl`from OpenZeppelin.

Each modules define the roles useful to restricts its functions.

By default, the `admin` has all the roles and this behavior is defined in the `AuthorizationModule` by overriding the function `hasRole`.

See also [docs.openzeppelin.com - AccessControl](https://docs.openzeppelin.com/contracts/5.x/api/access#AccessControl)

#### Role list

Here the list of roles and their 32 bytes identifier.

|                       | Defined in                      | 32 bytes identifier                                          |
| --------------------- | ------------------------------- | ------------------------------------------------------------ |
| DEFAULT_ADMIN_ROLE    | OpenZeppelin<br />AccessControl | 0x0000000000000000000000000000000000000000000000000000000000000000 |
| **Core Modules**      |                                 |                                                              |
| BURNER_ROLE           | BurnModule                      | 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848 |
| MINTER_ROLE           | MintModule                      | 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 |
| ENFORCER_ROLE         | EnforcementModule               | 0x973ef39d76cc2c6090feab1c030bec6ab5db557f64df047a4c4f9b5953cf1df3 |
| PAUSER_ROLE           | PauseModule                     | 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a |
| **Extension Modules** |                                 |                                                              |
| SNAPSHOOTER_ROLE      | SnashotModule                   | 0x809a0fc49fc0600540f1d39e23454e1f6f215bc7505fa22b17c154616570ddef |
| DEBT_ROLE             | DebtModule                      | 0xc6f3350ab30f55ce45863160fc345c1663d4633fe7cacfd3b9bbb6420a9147f8 |
| DOCUMENT_ROLE         | DocumentModule                  | 0xdd7c9aafbb91d54fb2041db1d5b172ea665309b32f5fffdbddf452802a1e3b20 |
| ERC20ENFORCER_ROLE    | ERC20EnforcementModule          | 0xd62f75bf68b069bc8e2abd495a949fafec67a4e5a5b7cb36aedf0dd51eec7e72 |
| **Option Modules**    |                                 |                                                              |
| CROSS_CHAIN_ROLE      | ERC20CrossChain                 | 0x620d362b92b6ef580d4e86c5675d679fe08d31dff47b72f281959a4eecdd036a |
| BURNER_FROM_ROLE      | ERC20CrossChain                 | 0x5bfe08abba057c54e6a28bce27ce8c53eb21d7a94376a70d475b5dee60b6c4e2 |



#### Schema

This schema contains the different roles and their restricted functions.



![RBAC-diagram-RBAC.drawio](./doc/schema/accessControl/RBAC-diagram-RBAC.drawio.png)

The OpenZepplin functions `grantRole`and `revokeRole`can be used by the admin to grant and revoke role to an address.

#### Transfer adminship

To transfer the adminship to a new admin, the current admin must call two functions:

1) `grantRole()` by specifying the DEFAULT_ADMIN_ROLE identifier and the new admin address
2) `renounceRole()` to revoke the DEFAULT_ADMIN_ROLE from its own account.

The new admin can also revoke role from the current/old admin by calling `revokeRole`.

It is also possible to have several different admin.

### Engines

Engines are external smart contracts called by CMTAT modules.

These engines are **optional** and their addresses can be left to zero.

More details are available in [./doc/general/Engine.md](./doc/general/Engine.md)

![Engine-Engine.drawio](./doc/schema/drawio/Engine-Engine.drawio.png)

#### RuleEngine (IERC-1404)

The `RuleEngine` is an external contract used to apply transfer restriction to the CMTAT through whitelisting, blacklisting,...

This contract is defined in the `ValidationModule`.

An example of RuleEngine is also available on [GitHub](https://github.com/CMTA/RuleEngine).

Here is the list of the different version available for each CMTAT version.

| CMTAT version           | RuleEngine                                                   |
| ----------------------- | ------------------------------------------------------------ |
| CMTAT v3.0.0            | <To do>                                                      |
| CMTAT 2.5.0 (unaudited) | RuleEngine >= [v2.0.3](https://github.com/CMTA/RuleEngine/releases/tag/v2.0.3) (unaudited) |
| CMTAT 2.4.0 (unaudited) | RuleEngine >=v2.0.0<br />Last version: [v2.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v2.0.2)(unaudited) |
| CMTAT 2.3.0             | [RuleEngine v1.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2) |
| CMTAT 2.0 (unaudited)   | [RuleEngine 1.0](https://github.com/CMTA/RuleEngine/releases/tag/1.0) (unaudited) |
| CMTAT 1.0               | No ruleEngine available                                      |

This contract acts as a controller and can call different contract rules to apply rules on each transfer.

A possible rule is a whitelist rule where only the address inside the whitelist can perform a transfer

##### Requirement

Since the version 2.4.0, the requirement to use a RuleEngine are the following:

> The `RuleEngine` must import and implement the interface `IRuleEngine` which declares the function `transferred` and `canApprove`with several other functions related to IERC1404.

This interface can be found in [./contracts/interfaces/engine/IRuleEngine.sol](./contracts/interfaces/engine/IRuleEngine.sol).

Warning: The `RuleEngine` has to restrict the access of the function `transferred` to only the `CMTAT contract`. 

Before each transfer, the CMTAT calls the function `transferred` which is the entrypoint for the RuleEngine.

Further reading: [Taurus - Token Transfer Management: How to Apply Restrictions with CMTAT and ERC-1404](https://www.taurushq.com/blog/token-transfer-management-how-to-apply-restrictions-with-cmtat-and-erc-1404/) (version used CMTAT v2.4.0)

![Engine-RuleEngine-Base.drawio](./doc/schema/drawio/Engine-RuleEngine-Base.drawio.png)





Example of a CMTAT using the [CMTA ruleEngine](https://github.com/CMTA/RuleEngine):

In this example, the token holder calls the function `transfer` which triggers a call to the `RuleEngine` and the different rules associated.

![RuleEngine](./doc/schema/drawio/Engine-RuleEngine.drawio.png)

#### SnapshotEngine

Engine to perform snapshot on-chain. This engine is defined in the module `SnapshotModule`.

CMTAT implements only one function defined in the interface [ISnapshotEngine](./contracts/interfaces/engine/ISnapshotEngine.sol)

**Before** each transfer, the CMTAT calls the function `operateOnTransfer` which is the entrypoint for the SnapshotEngine.

```solidity
/*
* @dev minimum interface to define a SnapshotEngine
*/
interface ISnapshotEngine {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function operateOnTransfer(address from, address to, uint256 balanceFrom, uint256 balanceTo, uint256 totalSupply) external;
}
```



| CMTAT                            | SnapshotEngine                                               |
| -------------------------------- | ------------------------------------------------------------ |
| CMTAT v3.0.0                     | <To do>                                                      |
| CMTAT v2.3.0                     | SnapshotEngine v0.1.0 (unaudited)                            |
| CMTAT v2.4.0, v2.5.0 (unaudited) | Include inside SnapshotModule (unaudited)                    |
| CMTAT v2.3.0                     | Include inside SnapshotModule (unaudited)                    |
| CMTAT v1.0.0                     | Include inside SnapshotModule, but not gas efficient (audited) |

#### DebtEngine

This engine can be used to configure Debt and Credits Events info

- It defined in the `DebtEngineModule` (option module)
- It extends the `DebtModule`(extension module) by allowing to set Credit Events while the DebtModule only allows to set debt info. 
- If a `DebtEngine` is configured, the function `debt`() will return the debt configured by the RuleEngine instead of the `DebtModule`.

CMTAT only implements two functions, available in the interface [IDebtEngine](./contracts/interfaces/engine/IDebtEngine.sol) to get information from the debtEngine.

```solidity
interface IDebtEngine is IDebtEngine {
    function debt() external view returns(IDebtGlobal.DebtBase memory);
    function creditEvents() external view returns(IDebtGlobal.CreditEvents memory);
}
```

Use an external contract provides two advantages: 

- Reduce code size of CMTAT, which is near of the maximal size limit 
- Allow to manage this information for several different tokens  (CMTAT or not).

Here is the list of the different version available for each CMTAT version.

| CMTAT version            | DebtEngine                                                   |
| ------------------------ | ------------------------------------------------------------ |
| CMTAT v3.0.0             | <To do>                                                      |
| CMTAT v2.5.0 (unaudited) | [DebtEngine v0.2.0](https://github.com/CMTA/DebtEngine/releases/tag/v0.2.0) (unaudited) |

#### DocumentEngine (IERC-1643)

The `DocumentEngine` is an external contract to support [*ERC-1643*](https://github.com/ethereum/EIPs/issues/1643) inside CMTAT, a standard proposition to manage document on-chain. This standard is notably used by [ERC-1400](https://github.com/ethereum/eips/issues/1411) from Polymath. 

This engine is defined in the module `DocumentModule`

This EIP defines a document with three attributes:

- A short name (represented as a `bytes32`)
- A generic URI (represented as a `string`) that could point to a website or other document portal.
- The hash of the document contents associated with it on-chain.

CMTAT only implements two functions from this standard, available in the interface [IERC1643](./contracts/interfaces/tokenization/draft-IERC1643.sol) to get the documents from the documentEngine.

```solidity
interface IERC1643 {
function getDocument(bytes32 _name) external view returns (string memory , bytes32, uint256);
function getAllDocuments() external view returns (bytes32[] memory);
}
```

The `DocumentEngine` has to import and implement this interface. To manage the documents, the engine is completely free on how to do it.

Use an external contract provides two advantages: 

- Reduce code size of CMTAT, which is near of the maximal size limit 
- Allow to manage documents for several different tokens  (CMTAT or not).

Here is the list of the different versions available for each CMTAT version.

| CMTAT version            | DocumentEngine                                               |
| ------------------------ | ------------------------------------------------------------ |
| CMTAT v3.0.0             | <To do>                                                      |
| CMTAT v2.5.0 (unaudited) | [DocumentEngine v0.3.0](https://github.com/CMTA/DocumentEngine/releases/tag/v0.3.0) (unaudited) |

#### AuthorizationEngine (Deprecated)

> Warning: this engine has been removed since CMTAT v3.0.0

The `AuthorizationEngine` was an external contract to add supplementary check on AccessControl (functions `grantRole` and `revokeRole`) from the CMTAT. Since delegating access rights to an external contract is complicated and it is better to manage access control directly in CMTAT, we removed it in version 3.0.0.

There was only one prototype available: [CMTA/AuthorizationEngine](https://github.com/CMTA/AuthorizationEngine)

| CMTAT version                          | AuthorizationEngine                    |
| -------------------------------------- | -------------------------------------- |
| CMTAT v3.0.0                           | Removed                                |
| CMTAT v2.4.0, 2.5.0, 2.5.1 (unaudited) | AuthorizationEngine v1.0.0 (unaudited) |
| CMTAT 2.3.0 (audited)                  | Not available                          |
| CMTAT 1.0 (audited)                    | Not available                          |

----

## Functionality details

### Gasless support (ERC-2771 / MetaTx module)

The CMTAT supports client-side gasless transactions using the [ERC-2771](https://eips.ethereum.org/EIPS/eip-2771)

The contract uses the OpenZeppelin contract `ERC2771ContextUpgradeable`, which allows a contract to get the original client with `_msgSender()` instead of the feepayer given by `msg.sender` while allowing upgrades on the main contract (see *Deployment via a proxy* above).

At deployment, the parameter  `forwarder` inside the CMTAT contract constructor has to be set  with the defined address of the forwarder. 

After deployment:

- In standalone deployment, the forwarder is immutable and can not be changed after deployment.

- In upgradeable deployment (with a proxy), it is possible to change the forwarder by deploying a new implementation. This is possible because the forwarder is stored inside the implementation contract bytecode instead of the storage of the proxy.

References:

- [OpenZeppelin Meta Transactions](https://docs.openzeppelin.com/contracts/5.x/api/metatx)

- OpenGSN has deployed several forwarders, see their [documentation](https://docs.opengsn.org/contracts/#receiving-a-relayed-call) to see some examples.

### Enforcement / Transfer restriction

There are several ways to restrict transfer as well as burn/mint operation

**Enforcement Module**

- Specific addresses can be frozen with the following ERC-3643 functions `setAddressFrozen`and `batchSetAddressFrozen`

**ERC20EnforcementModule**

- A part of the balance of a specific address can be frozen with the following ERC3643 function `freezePartialTokens` and `unfreezePartialTokens`
- Transfer/burn can be forced by the admin  (ERC20EnforcementModule) with the following ERC3643 function `forcedTransfer`.
  - In this case, if a part of the balance is frozen, the tokens are unfrozen before being burnt or transferred.

**PauseModule**

- Transfers can be put in pause with the following ERC3643 function `pause`and `unpause`
- Contract can be deactivated with the function `deactivateContract`

When an address is frozen, it is not possible to mint tokens to this address or burn its tokens. To move tokens from a frozen address, the issuer must use the function `forcedTransfer`.

#### Schema

Here a schema describing the different check performed during:

- transfer & transferFrom
- burn / mint (supply management)
- burn / mint for crosschain transfers

![transfer_restriction.drawio](./doc/schema/drawio/transfer_restriction.drawio.png)



#### Deactivate contracte (PauseModule)

Since the version v2.3.1, a function `deactivateContract` is implemented in the PauseModule to deactivate the contract.

If a contract is deactivated, it is no longer possible to perform transfer and burn/mint operations.

##### Kill (previous version)

CMTAT initially supported a `kill()` function relying on the SELFDESTRUCT opcode (which effectively destroyed the contract's storage and code).
However, Ethereum's [Cancun upgrate](https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/cancun.md) (rolled out in Q1 of 2024)  has removed support for SELFDESTRUCT (see [EIP-6780](https://eips.ethereum.org/EIPS/eip-6780)).

The `kill()` function will therefore not behave as it was used, and we have replaced it by the function `deactivateContract` .

##### How it works

This function sets a boolean state variable `isDeactivated` to true and puts the contract in the pause state.
The function `unpause `is updated to revert if the previous variable is set to true, thus the contract is in the pause state "forever".

The consequences are the following:

- In standalone deployment, this operation is irreversible, it is not possible to rollback.
- In upgradeable deployment (with a proxy), it is still possible to rollback by deploying a new implementation which sets the variable `isDeactivated`to false.

#### Supply management (burn & mint)

This tab summarizes the different behavior of burn/mint functions if:

- The target address is frozen (EnforcementModule)
- The target address does not have enough active balance (ERC20EnforcementModule)
- If a ruleEngine is configured (ValidationModuleInternal)

|                                                              | burn      | batchBurn | burnFrom        | mint      | batchMint | crosschain burn | Crosschain mint | forcedTransfer   |
| ------------------------------------------------------------ | --------- | --------- | --------------- | --------- | --------- | --------------- | --------------- | ---------------- |
| Module                                                       | ERC20Burn | ERC20Burn | ERC20CrossChain | ERC20Mint | ERC20Mint | ERC20CrossChain | ERC20CrossChain | ERC20Enforcement |
| Module type                                                  | Core      | Core      | Options         | Core      | Core      | Options         | Options         | Extensions       |
| Allow operation on a frozen address                          | &#x2612;  | &#x2612;  | &#x2612;        | &#x2612;  | &#x2612;  | &#x2612;        | &#x2612;        | &#x2611;         |
| Unfreeze missing funds if active balance is not enough<br />(ERC20EnforcementModule) | &#x2612;  | &#x2612;  | &#x2612;        | -         | -         | &#x2612;        | -               | &#x2611;         |
| Call the RuleEngine                                          | &#x2611;  | &#x2611;  | &#x2611;        | &#x2611;  | &#x2611;  | &#x2611;        | &#x2611;        | &#x2612;         |



## Deployment model 

Contracts for deployment are available in the directory [./contracts/deployment](./contracts/deployment)

| CMTAT Model          | Description                                                  | Contract                                                     |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Standalone           | Deployment without proxy <br />(immutable)                   | [CMTATStandalone](./contracts/deployment/CMTATStandalone.sol) |
| Upgradeable          | Deployment with a standard proxy (Transparent or Beacon Proxy) | [CMTATUpgradeable](./contracts/deployment/CMTATUpgradeable.sol) |
| Upgradeable UUPS     | Deployment with a UUPS proxy                                 | [CMTATUpgradeableUUPS](./contracts/deployment/CMTATUpgradeableUUPS.sol) |
| Upgradeable ERC-1363 | ERC1363 Proxy version                                        | [CMTATUpgradeableERC1363](./contracts/deployment/ERC1363/CMTATUpgradeableERC1363.sol) |
| Standalone ERC-1363  | ERC1363 Standalone version                                   | [CMTATStandaloneERC1363](./contracts/deployment/ERC1363/CMTATStandaloneERC1363.sol) |
| Standalone Light     | Standalone deployment                                        | [CMTATStandaloneLight](./contracts/deployment/light/CMTATStandaloneLight.sol) |
| Upgradeable Light    | Upgradeable deployment                                       | [CMTATUpgradeableLight](./contracts/deployment/light/CMTATUpgradeableLight.sol) |

### Standalone

To deploy CMTAT without a proxy, in standalone mode, you need to use the contract version `CMTATStandalone`.

Here the surya inheritance schema:

![surya_inheritance_CMTAT_STANDALONE.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATStandalone.sol.png)

### Upgradeable (with a proxy)

The CMTAT supports deployment via a proxy contract.  Furthermore, using a proxy permits to upgrade the contract, using a standard proxy upgrade pattern.

- The  implementation contract to use with a TransparentProxy  is the `CMTATUpgradeable`.
- The  implementation contract to use with a UUPSProxy  is the `CMTATUpgradeableUUPS`.

Please see the OpenZeppelin [upgradeable contracts documentation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable) for more information about the proxy requirements applied to the contract.

See the OpenZeppelin [Upgrades plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for more information about plugin upgrades in general.

#### Inheritance

- UUPS

![surya_inheritance_CMTAT_PROXY_UUPS.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATUpgradeableUUPS.sol.png)

- Proxy standard



![surya_inheritance_CMTAT_PROXY.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATUpgradeable.sol.png)

#### Implementation details

##### Storage

CMTAT also implements the standard [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201) to manage the storage location. See [this article](https://www.rareskills.io/post/erc-7201) by RareSkills for more information

##### Initialize functions

For wrapper modules, we have removed the public function `{ContractName}_init`to reduce the size of the contracts since inside the public initializer function to initialize your proxy, you have to call the difference functions `__{ContractName}_init_unchained`.

Do not forget to call the functions `init_unchained` from the parent initializer if you create your own contract from the different modules.

As indicated in the [OpenZeppelin documentation](https://docs.openzeppelin.com/contracts/5.x/upgradeable#multiple-inheritance): 

> Initializer functions are not linearized by the compiler like constructors. Because of this, each `__{ContractName}_init` function embeds the linearized calls to all parent initializers. As a consequence, calling two of these `init` functions can potentially initialize the same contract twice.
>
> The function `__{ContractName}_init_unchained` found in every contract is the initializer function minus the calls to parent initializers, and can be used to avoid the double initialization problem, but doing this manually is not recommended. We hope to be able to implement safety checks for this in future versions of the Upgrades Plugins.

### ERC-1363

[ERC-1363](https://eips.ethereum.org/EIPS/eip-1363) is an extension interface for ERC-20 tokens that supports executing code on a recipient contract after transfers, or code on a spender contract after approvals, in a single transaction.

Two dedicated versions (proxy and standalone) implementing this standard are available.

More information on this standard here: [erc1363.org](https://erc1363.org), [RareSkills - ERC-1363](https://www.rareskills.io/post/erc-1363)

#### Inheritance

- CMTAT ERC-1363 Base

![surya_inheritance_CMTAT_ERC1363_BASE.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATERC1363Base.sol.png)



- CMTAT PROXY ERC-1363

![surya_inheritance_CMTAT_PROXY_ERC1363.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATUpgradeableERC1363.sol.png)



- CMTAT Proxy ERC-1363

![surya_inheritance_CMTAT_STANDALONE_ERC1363.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATStandaloneERC1363.sol.png)

- CMTAT  ERC1363Base

![surya_inheritance_CMTAT_STANDALONE_ERC1363.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATERC1363Base.sol.png)

### Light version

The light version only includes core modules.

It also includes a function `forceBurn`to allow the admin to burn a token from a frozen address.

- CMTAT Proxy

![surya_inheritance_CMTAT_ERC1363_BASE.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATUpgradeableLight.sol.png)

- CMTAT Light

![surya_inheritance_CMTAT_ERC1363_BASE.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATStandaloneLight.sol.png)

- CMTATBaseCore

![surya_inheritance_CMTAT_ERC1363_BASE.sol](./doc/schema/surya_inheritance/surya_inheritance_CMTATBaseCore.sol.png)

### Factory

Factory contracts are available to deploy the CMTAT with a beacon proxy, a transparent proxy or an UUPS proxy.

These contracts have now their own GitHub project: [CMTAT Factory](https://github.com/CMTA/CMTATFactory)

| CMTAT version                     | CMTAT Factory                                                |
| --------------------------------- | ------------------------------------------------------------ |
| CMTAT v3.0.0                      | CMTAT Factory v0.1.0 (unaudited)                             |
| CMTAT v2.5.0 / v2.5.1 (unaudited) | Available within CMTAT <br />see contracts/deployment<br />(unaudited) |
| CMTAT 2.3.0 (audited)             | Not available                                                |
| CMTAT 1.0 (audited)               | Not available                                                |

Further reading: [Taurus - Making CMTAT Tokenization More Scalable and Cost-Effective with Proxy and Factory Contracts](https://www.taurushq.com/blog/cmtat-tokenization-deployment-with-proxy-and-factory/) (version used CMTAT v2.5.1)

----

## Documentation

Here a summary of the main documents:

| Document                            | Link/Files                                                   |
| ----------------------------------- | ------------------------------------------------------------ |
| Documentation of the modules API.   | [doc/modules](doc/modules)                                   |
| How to use the project + toolchains | [doc/USAGE.md](doc/USAGE.md)                                 |
| Project architecture                | [architecture.pdf](./doc/schema/drawio/architecture.pdf)     |
| FAQ                                 | [doc/general/FAQ.md](doc/general/FAQ.md)                     |
| Crosschain transfers                | [doc/general/crosschain-bridge-support.md](doc/general/crosschain-bridge-support.md) |

CMTA providers further documentation describing the CMTAT framework in a platform-agnostic way, and covering legal aspects, see

-  [CMTA Token (CMTAT)](https://cmta.ch/standards/cmta-token-cmtat)
-  [Standard for the tokenization of shares of Swiss corporations using the distributed ledger technology](https://cmta.ch/standards/standard-for-the-tokenization-of-shares-of-swiss-corporations-using-the-distributed-ledger-technology)

### Further reading

- [CMTA - A comparison of different security token standards](https://cmta.ch/news-articles/a-comparison-of-different-security-token-standards)
- [Taurus - Security Token Standards: A Closer Look at CMTAT](https://www.taurushq.com/blog/security-token-standards-a-closer-look-at-cmtat/)
- [Taurus - Equity Tokenization: How to Pay Dividend On-Chain Using CMTAT](https://www.taurushq.com/blog/equity-tokenization-how-to-pay-dividend-on-chain-using-cmtat/) (CMTAT v2.4.0)
- [Taurus - Token Transfer Management: How to Apply Restrictions with CMTAT and ERC-1404](https://www.taurushq.com/blog/token-transfer-management-how-to-apply-restrictions-with-cmtat-and-erc-1404/) (CMTAT v2.4.0)
- [Taurus - Making CMTAT Tokenization More Scalable and Cost-Effective with Proxy and Factory Contracts](https://www.taurushq.com/blog/cmtat-tokenization-deployment-with-proxy-and-factory/) (CMTAT v2.5.1)
- [Taurus - Addressing the Privacy and Compliance Challenge in Public Blockchain Token Transactions](https://www.taurushq.com/blog/enhancing-token-transaction-privacy-on-public-blockchains-while-ensuring-compliance/) (Aztec)

------

## Security

### Vulnerability disclosure

Please see [SECURITY.md](./SECURITY.MD).


### Module

See the code in [modules/security](./contracts/modules/security).

Access control is managed thanks to the module `AuthorizationModule`.

### Audit

The contracts have been audited by [ABDKConsulting](https://www.abdk.consulting/), a globally recognized firm specialized in smart contracts security.

#### First audit - September 2021

Fixed version: [1.0](https://github.com/CMTA/CMTAT/releases/tag/1.0)

Fixes of security issues discovered by the initial audit were reviewed by ABDK and confirmed to be effective, as certified by the [report released](doc/audits/ABDK-CMTAT-audit-20210910.pdf) on September 10, 2021, covering [version c3afd7b](https://github.com/CMTA/CMTAT/tree/c3afd7b4a2ade160c9b581adb7a44896bfc7aaea) of the contracts.
Version [1.0](https://github.com/CMTA/CMTAT/releases/tag/1.0) includes additional fixes of minor issues, compared to the version retested.

A summary of all fixes and decisions taken is available in the file [CMTAT-Audit-20210910-summary.pdf](doc/audits/CMTAT-Audit-20210910-summary.pdf) 

#### Second audit - March 2023

Fixed version: [v2.3.0](https://github.com/CMTA/CMTAT/releases/tag/v2.3.0)

The second audit covered version [2.2](https://github.com/CMTA/CMTAT/releases/tag/2.2).

Version v2.3.0 contains the different fixes and improvements related to this audit.

The report is available in [ABDK_CMTA_CMTATRuleEngine_v_1_0.pdf](doc/audits/ABDK_CMTA_CMTATRuleEngine_v_1_0/ABDK_CMTA_CMTATRuleEngine_v_1_0.pdf). 

### Tools

#### [Aderyn](https://github.com/Cyfrin/aderyn)

| Version | File                                                         |
| ------- | ------------------------------------------------------------ |
| v3.0.0  | [v3.0.0-aderyn-report.md](doc/audits/tools/aderyn/v3.0.0-aderyn-report.md) |

#### Slither

You will find the report produced by [Slither](https://github.com/crytic/slither) in 

| Version | File                                                         |
| ------- | ------------------------------------------------------------ |
| v3.0.0  | [v3.0.0-slither-report.md](doc/audits/tools/slither/v3.0.0-slither-report.md) |
| v2.5.0  | [v2.5.0-slither-report.md](doc/audits/tools/slither/v2.5.0-slither-report.md) |
| v2.3.0  | [v2.3.0-slither-report.md](doc/audits/tools/slither/v2.3.0-slither-report.md) |

#### [Mythril](https://github.com/Consensys/mythril)

| Version | File                                                         |
| ------- | ------------------------------------------------------------ |
| v2.5.0  | [mythril-report-standalone.md](doc/audits/tools/mythril/v2.5.0/myth_standalone_report.md)<br />[mythril-report-proxy.md](doc/audits/tools/mythril/v2.5.0/myth_proxy_report.md)<br /> |



### Test

A code coverage is available in [index.html](doc/test/coverage/index.html).

![coverage](./doc/general/coverage.png)


### Remarks

As with any token contract, access to the owner key must be adequately restricted.
Likewise, access to the proxy contract must be restricted and seggregated from the token contract.

---

## Other implementations

Two versions are available for the blockchain [Tezos](https://tezos.com)
- [CMTAT FA2](https://github.com/CMTA/CMTAT-Tezos-FA2) Official version written in SmartPy
- [@ligo/cmtat](https://github.com/ligolang/CMTAT-Ligo/) Unofficial version written in Ligo
  - See also [Tokenization of securities on Tezos by Frank Hillard](https://medium.com/@frank.hillard_62931/tokenization-of-securities-on-tezos-2e3c3e90fc5a)

A specific version is available for [Aztec](https://aztec.network/)

- [Aztec Private CMTAT](https://github.com/taurushq-io/private-CMTAT-aztec)
  - See also [Taurus - Addressing the Privacy and Compliance Challenge in Public Blockchain Token Transactions](https://www.taurushq.com/blog/enhancing-token-transaction-privacy-on-public-blockchains-while-ensuring-compliance/) 

## Configuration & toolchain

The project is built with [Hardhat](https://hardhat.org) and uses [OpenZeppelin](https://www.openzeppelin.com/solidity-contracts)

More information in [doc/USAGE.md](doc/USAGE.md)

- hardhat.config.js
  - Solidity 0.8.28
  - EVM version: Prague (Pectra upgrade)
  - Optimizer: true, 200 runs

- Package.json
  - OpenZeppelin Contracts (Node.js module): [v5.3.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.3.0) 
  - OpenZeppelin Contracts Upgradeable (Node.js module): [v5.3.0](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.3.0)


## Contract size

```bash
npm run-script size
```


![contract-size](./doc/general/contract-size.png)
## Intellectual property

The code is copyright (c) Capital Market and Technology Association, 2018-2025, and is released under [Mozilla Public License 2.0](./LICENSE.md).
