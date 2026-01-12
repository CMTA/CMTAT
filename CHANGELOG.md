# CHANGELOG

Please follow [https://changelog.md conventions and the other conventions below

## Semantic Version 2.0.0

Given a version number MAJOR.MINOR.PATCH, increment the:

1. MAJOR version when the new version makes:
   -  Incompatible proxy **storage** change internally or through the upgrade of an external library (OpenZeppelin)
   - A significant change in external APIs (public/external functions) or in the internal architecture
2. MINOR version when the new version adds functionality in a backward compatible manner
3. PATCH version when the new version makes backward compatible bug fixes

See [https://semver.org](https://semver.org)

## Type of changes

- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

Reference: [keepachangelog.com/en/1.1.0/](https://keepachangelog.com/en/1.1.0/)

## Checklist

> Before a new release, perform the following tasks

- Code: Update the version name in the `Version` core module, variable VERSION
- Run linter

> npm run-script lint:all:prettier

- Documentation
  - Perform a code coverage and update the files in the corresponding directory [./doc/general/test/coverage](./doc/general/test/coverage)
  - Perform an audit with several audit tools (Aderyn and Slither), update the report in the corresponding directory  [./doc/audits/tools](./doc/audits/tools)
  - Update surya doc by running the 3 scripts in [./doc/script](./doc/script)
  
  - Update changelog



## 3.2.0

> **Note:** This version has not been audited.

### Added

- Support for **ERC-7943** ([#337](https://github.com/CMTA/CMTAT/issues/337)).
- New dedicated deployment variant with **DebtEngine** support (see *Removed* section for rationale).
- **IRuleEngine**: ERC-165 support added ([#342](https://github.com/CMTA/CMTAT/issues/342)) to enable interface compliance checks.
- New base contract **CMTATBaseAccessControl** ([#350](https://github.com/CMTA/CMTAT/issues/350)).

### Changed

- **Transfer** now reverts with specific errors when the contract is paused or deactivated ([#338](https://github.com/CMTA/CMTAT/issues/338)) to improve error clarity.
- The `approve` function now reverts when the contract is paused for all deployment variants except **Light** ([#335](https://github.com/CMTA/CMTAT/issues/335)).

### Removed

- **DocumentEngine** and **SnapshotEngine** removed from constructors and initialization ([#343](https://github.com/CMTA/CMTAT/issues/343)) to simplify deployment and reduce bytecode size.
- **DebtDeployment**: DebtEngine support removed and moved to a dedicated deployment variant ([#339](https://github.com/CMTA/CMTAT/issues/339)) to reduce contract size and enable additional modules in DebtEngine-based deployments.

## 3.1.0 - 20251209

> This version is not audited

**Fixed**

- [Misleading NatSpec Comments](https://github.com/CMTA/CMTAT/issues/330)
- [Incorrect error parameters in _unfreezeTokens](https://github.com/CMTA/CMTAT/issues/329)
- [CMTATUpgradeableUUPS contract may be not initializable](https://github.com/CMTA/CMTAT/issues/327)
- [CMTATBaseAllowlist - Redundant State Checks](https://github.com/CMTA/CMTAT/issues/332)
- [Snpashot update - CEI pattern](https://github.com/CMTA/CMTAT/issues/326)

**Added**

- New module `CCIPModule` with two functions `getCCIPAdmin` and `setCCIPAdmin` 
  - Reason: it allows the CCIP admin to enable the CMTAT token in Chainlink CCIP, without the need of requesting assistance to [Chainlink](https://chain.link).
- Add explicit support of [ERC-5679](https://eips.ethereum.org/EIPS/eip-5679) for minting and burning
  - Reason: this ERC was already supported in v3.0.0 but not through a dedicated interface and ERC-165 identifier.
  - Details: `IERC7551Burn` and `IERC7551Mint` will inherits from respectively the burn and mint part of ERC-5679.
- In `ERC7551Module`, the function `setTerms` emits the `Terms` event
  - Reason: meet the specification of the draft ERC [ERC-7551](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg-reworked/25477).
- Create specific module `ERC20CrossChain` for cross-chain transfers (ERC-7802 and other burn/mint related function), code previously put in `CMTATBaseCrossChain`.

**Changed**

- Rename `BaseModule` into `VersionModule`

  - Reason: This module contains only the CMTAT version. This avoid also the confusion with CMTAT Base modules.
- Access control: in wrapper modules, all access control is made through internal functions. These functions must be now implemented in CMTAT base module

  - Reason: this allows to use a different access control (e.g. [ownership](https://docs.openzeppelin.com/contracts/5.x/) or [Access Manager](https://docs.openzeppelin.com/contracts/5.x/api/access#AccessManager)) by implementing a new CMTAT Base module without the need of modifying wrapper modules.
- Cross-Chain
  - Move cross-chain functionalities (ERC-7802) from `CMTATBaseCrossChain` to a new module `ERC20CrossChain`.
  - The allowance is no longer required to burn tokens to follow Optimism Superchain ERC20 and OpenZeppelin implementation
    See [ERC20BridgeableUpgradeable.so](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/e725abddf1e01cf05ace496e950fc8e243cc7cab/contracts/token/ERC20/extensions/draft-ERC20BridgeableUpgradeable.sol) & [SuperchainERC20.sol](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/SuperchainERC20.sol#L43). See issue [328#issuecomment-3455923837](https://github.com/CMTA/CMTAT/issues/328#issuecomment-3455923837)

**Library**

- Update Openzeppelin standard and upgradeable version to [v5.5.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.5.0)

**Documentation** (README)

- Reference the new draft version of [ERC-7551](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg-reworked/25477)
- Reference [ERC-5679](https://eips.ethereum.org/EIPS/eip-5679) as supported ERC by CMTAT
- Add section to explain cross-chain bridge support ([Chainlink CCIP](https://docs.chain.link/ccip/concepts/cross-chain-token/evm) and [ERC-7802](https://eips.ethereum.org/EIPS/eip-7802) mainly)
- Add summary tab for CMTAT framework functionalities to help build CMTAT version for other blockchains
- Add audit reports made by [Nethermind Audit Agents](https://auditagent.nethermind.io)


## 3.0.0 - 2025-08-28

- Major release audited by [Halborn](https://www.halborn.com)
- Improved comments and documentation

See changelogs of the rc versions for details.

Main changes with the last audited release (v2.3.0):

**Added**

- Add support for several new ERC standard:
  - Tokenization: [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) (without on-chain identity), [ERC-7551 (
    equivalence)](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg/16416), [ERC-1363 (deployment version)](https://eips.ethereum.org/EIPS/eip-1363), [ERC-1643 (Document Management)](https://github.com/ethereum/EIPs/issues/1643),...
  - Technicals: [ERC-7201 (proxy storage management)](https://eips.ethereum.org/EIPS/eip-7201), [ERC-7802 (cross-chain transfers)](https://eips.ethereum.org/EIPS/eip-7802), [ERC-1822 (UUPS / deployment version](https://eips.ethereum.org/EIPS/eip-1822)...
- Add several functions to optimize contract call: ERC-3643 `batchMint`, ERC-3643 `batchBurn`, ERC-3643 `batchTransfer` (restricted)
- Rename several functions, e.g:`burn`instead of `forceBurn`
- Add ERC-3643 function `forcedTransfer`
- Add several new engines: DebtEngine, SnapshotEngine and DocumentEngine
- Add several new deployment version:
  - CMTAT Proxy and standalone
  - CMTAT for ERC-1363 (proxy and standalone)
  - CMTAT for deployment with UUPS proxy
  - CMTAT ERC-7551 for better compatibility with [ERC-7551](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg/16416)

**Changed**

- Update Solidity (0.8.30) & OpenZeppelin version (v.5.4.0)
- Update several function names to be compatible with [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643)

## 3.0.0-rc.7 - 2025-08-04

- Add missing compliance check (pause, address freeze and RuleEngine) for `batchTransfer` 
  - Create a virtual function `_minterTransferOverride` in ERC20MintModule.
  - This function is then overridden in `CMTATBaseCommon` to perform the required check
- Add the same check for `batchMint/batchBurn`for CMTAT core (light) version
- Add several tests to check these modification

## 3.0.0-rc.6 - 2025-07-31

- Perform recommendations from the audit report (Halborn)
  - Main change: add a new ERC-1404 code if the contract is deactivated

## 3.0.0-rc.5 - 2025-06-27

- Add & improve Solidity Natspec comment
  - Few improvement as a result (e.g rename return variables)
- Improve & update documentation

## 3.0.0-rc.4 - 2025-06-24

- Fix typo for IERC3643IComplianceContract
  -- IERC3743IComplianceContract -> IERC3643IComplianceContract
- CMTATBaseERC20CrossChain:
  Put events before internal functions calls `mintOverride`and `burnOverride`(avoid reentrancy-event)

## 3.0.0-rc.3 - 2025-06-24

- ERC-7551
  - Create specific option module ERC-7551
  - Create specific deployment version for ERC-7551
- Add prefix numbers for each CMTAT base file depending of inheritance level
- ERC20 Burn and Mint modules: create internal version
  - ERC20BurnModuleInternal & ERC20MintModuleInternal

- Debt version
  - Add function `setCreditEvents`in `DebtModule`
  - Remove ERC-1404 inheritance from `CMTATBaseDebt` to reduce contract code size
- ERC-1404
  - Create a second interface `ERC1404Extend` which inherits from `ERC1404`
    - Add function `detectTransferRestrictionFrom`in `ERC-1404Extend`
    - Implement function `detectTransferRestrictionFrom`in ValidationModuleERC1404
- Upgrade solidity version in Hardhat config file from 0.8.28 to 0.8.30

## 3.0.0-rc.2 - 2025-06-04

- Deployment version
  - Add CMTAT Allowlist (Whitelist) version
  - Add CMTAT debt version
    - Which means that `CMTATStandalone` and `CMTATUpgradeable`  no longer included  `DebtModule` and `DebtEngineModule`
- Rename `forceBurn`in `forcedBurn`to use the same semantic as ERC-3643 `forcedTransfer`
- Rename `balanceInfo`in `batchBalanceOf` to use the same semantic as ERC-3643 `batchBurn`and `batchMint`
- Add several new interfaces for module, see `interfaces/modules`
- Add a parameter `burner`and `minter`in the events Mint & Burn (ERC20MintModule / ERC20BurnModule)
- Improve documentation & tests

## 3.0.0-rc.1 - 2025-05-15

- Move `MetaTx` module to the option folder
- Improve documentation

## 3.0.0-rc.0 - 2025-05-13

The main goal of this version since the last version 2.3.0 is:

- Add support for several new ERC standard (ERC-1363, ERC-1643, ERC-7802, ...)
  - Better compliance with the German law by implementing [ERC-7551](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg/16416)
  - Standardize several functions with ERC-3643
  - Payable token with the support of [ERC-1363](https://eips.ethereum.org/EIPS/eip-1363)  (specific deployment version)
  - Available from the previous version:
    - [UUPS](https://eips.ethereum.org/EIPS/eip-1822) proxy support (specific deployment version)
    - Document management with [ERC-1643](https://github.com/ethereum/eips/issues/1643) (requires DocumentEngine)
    - Better storage management for upgradeable contract with [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201)
- Optimize contract call (batch function)
- Be updated with the latest library (solidity & OpenZeppelin) and code practice

- There are also seven variation of the CMTAT for deployment:
  - CMTAT Proxy and standalone
  - CMTAT for ERC-1363 (proxy and standalone)
  - CMTAT for deployment with UUPS proxy
  - CMTAT light version (only main core modules)

### ValidationModule

- Separate logic in  several contracts:
  - ValidationModule (controllrs)
  - ValidationModuleCore (core)
  - ValidationModuleRuleEngineInternal (internal)
  - ValidationModuleRuleEngine (extensions)
  - ValidationModuleERC1404 (extensions)

### Core module

- ERC20BaseModule
  - Add function to update ERC20 Symbol and Name

- MintModule
  - Add function `batchTransfer`
- BaseModule: 
  - Keep only the VERSION variable, move the rest to `ExtraInformationModule` 
  - Add [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) function `version`

### Extensions

- Update `DocumentModule` to use a struct
- ERC20EnforcementModule: 
  - Add function`enforceTransfer` (forceTransfer)
- ExtraInformationModule
  - Terms are represented as document (name, hash, uri, last on-chain modification date).
  - Add [ERC-7551](https://ethereum-magicians.org/t/erc-7551-crypto-security-token-smart-contract-interface-ewpg/16416) function `setMetaData`

### Options

- Create `DebtEngineModule`
- Create `ERC20CrossChain`module, which implements  `IERC7802`([ERC-7802](https://eips.ethereum.org/EIPS/eip-7802))

### Deployment

- Add deployment version for [ERC-1363](https://eips.ethereum.org/EIPS/eip-1363)
- Add light deployment with only core modules
- Create a separate directory for factory contract. See [CMTATFactory](https://github.com/CMTA/CMTATFactory)

### Base contract

Add several base contracts to build the different deployment version:

- CMTATBase for CMTATStandalone/Upgradeable/UUPS
- CMTATBaseERC1363 for ERC-1363
- CMTATBaseCore for light deployment
- CMTATBaseGeneric to build non-ERC20 contracts (e.g ERC-721)

### Engine

- AuthorizationModule: Remove `AuthorizationEngine`
- SnapshotEngineModule: Add `SnapshotEngine` instead of `snapshotModule`. See also [SnapshotEngine](https://github.com/CMTA/SnapshotEngine)
- DebtEngine:  Engine configured in an option module 

### Technical

Library

- Update solidity to version 0.8.28
- Update OpenZeppelin to version 5.3.0

Technical details:

- Revert with custom error

## 2.5.1 - 2024-10-03

- Beacon Factory: deploy an implementation inside the constructor if no implementation is provided
- Run [myhtril](https://github.com/Consensys/mythril)

## 2.5.0 - 2024-09-10

- Change Solidity version to 0.8.27 (latest)
- Some slight improvements to the documentation

## 2.5.0-rc.0 - 2024-08-09

**Features**

- Add ERC-1643 (part of ERC-1400) for document management through an optional external contract called DocumentEngine (not yet available) [Add ERC-1643 support #267](https://github.com/CMTA/CMTAT/issues/267)
- Externalize the Debt and CreditEvent module to an optional external contract called DebtEngine (not yet available) [Add DebtEngine #271](https://github.com/CMTA/CMTAT/issues/271)
- CMTAT version compatible with UUPS proxy : more gas efficient than Transparent Proxy + no need of a proxy admin contract. See Upgradable Smart Contracts | What is a Smart Contract Proxy Pattern? [Add UUPS proxy support #270](https://github.com/CMTA/CMTAT/issues/270)
- Remove [flag](https://github.com/CMTA/CMTAT/blob/master/contracts/modules/wrapper/core/BaseModule.sol#L29) attribute, present since v2.3.0, which was not really used. [ #266](https://github.com/CMTA/CMTAT/issues/266)

**Technical**

- Change Solidity version to 0.8.26 (latest)
- Change EVM version to Cancun
- Remove truffle from dependencies, replaced by Hardhat. See [Consensys Announces the Sunset of Truffle and Ganache and New Hardhat Partnership](https://consensys.io/blog/consensys-announces-the-sunset-of-truffle-and-ganache-and-new-hardhat)
- Proxy Factory
  - use create2 with the library [Create2](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Create2.sol) from OpenZeppelin:
- Implement [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201) to manage memory to reduce memory collision when upgrading a proxy to a new implementation. [Use erc-7201 for namespace #272](https://github.com/CMTA/CMTAT/issues/272)

## 2.4.0 - 2024-05-03

The modifications between the version v2.3.0 and this version are not audited !!!

- Improve tests & update the code
- `ERC20SnapshotInternal` inherits from `ICMTATSnapshot`

## 2.4.0-rc.1 - 2024-03-19

The modifications between the version v2.3.0 and this version are not audited !!!

**snapshotModule**

- Create an interface `ICMTATSnapshot` with the main public functions for the SnapshotModule to make easier the calls to a contract including a snapshotModule, useful e.g. for debt payment.
- Replace `getSnapshotInfoBatch` by `SnapshotInfo`. This function  gets a user's balance specified in parameter and the total supply.
- Add a new function `SnapshotInfoBatch` to get several user's balances and the total supply.

**ERC20BaseModule**
Add a function `balanceInfo` to get the balance for a list of addresses and the total supply
 Useful to perform transfer restriction based on the user's balance (e.g vesting rule or partial lock).

**ValidationModule**
Create an internal function ` _validateTransferByModule` which performs check with others module (PauseModule & EnforcementModule)

**Other**

- Upgrade OpenZeppelin to the version [v5.0.2](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.2)
- Upgrade Solidity to the version [0.8.22](https://soliditylang.org/blog/2023/10/25/solidity-0.8.22-release-announcement/) in the truffle and hardhat config files.

## 2.4.0-rc.0 - 2024-01-29

The modifications between the version v2.3.0 and this version are not audited !!!

**New architecture for the RuleEngine** [#250](https://github.com/CMTA/CMTAT/pull/250)

- A new function `operateOnTransfer` is added and use inside the ValidationModule.
- Contrary to `validateTransfer`, this function has to be protected by an access control (if not implemented as view or pure)
- This function can be used to perform operation which modifies the state of the blockchain (storage) by the RuleEngine.
- The RuleEngine inherits now from *IRuleEngine* wich contains in its interface the function `operateOnTransfer` + IERC-1404
- The function `validateTransfer` is still available to verify a transfer without performing operation. The behavior is the same than with the previous CMTAT version.

**snapshotModule** [#256](https://github.com/CMTA/CMTAT/pull/256)

- Split the snapshotModuleInternal in two parts : one with the inheritance with ERC-20 and the other part with the base function and does not inherit from ERC-20.
  Thus, if we want to build a snapshotModule with the RuleEngine, we can use the base contract to avoid the inheritance with ERC-20.
- Add a function `getSnapshotInfoBatch` to avoid multiple calls when computing debt payment

**AuthorizationEngine** [#254](https://github.com/CMTA/CMTAT/pull/254)

- Add the AuthorizationEngine. With that, it is possible to add supplementary check on the functions `grantRole` and `revokeRole`without modifying the CMTAT.

**BurnModule**

- rename `forceBurn` and `forceBurnBatch` in `burn` and `burnBatch`
- Add a function `burnFrom` with a specific role (useful for bridge) for compatibility with CCIP [Ccip #260](https://github.com/CMTA/CMTAT/pull/260)
- Add a function `burnAndMint` to perform a burn/mint operation atomically.

**Gas optimization**

- Add factory contract for deployment with Transparent and beacon proxy [Contract factory #259](https://github.com/CMTA/CMTAT/pull/259)
- Remove useless init function in internal modules (Done) [remove init functions in wrapper modules #237](https://github.com/CMTA/CMTAT/pull/237)

**Other**

- Remove custom approval function [Remove custom function allowance #225](https://github.com/CMTA/CMTAT/issues/225) (Done)
- upgrade some JS libraries
- Upgrade OpenZeppelin to the version [v5.0.1](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.1)

## 2.3.1

This version contains breaking changes with the version v2.3.0.

- Remove useless functions init in wrapper modules [#230](https://github.com/CMTA/CMTAT/issues/230)
- Add missing tests in EnforcementModule [#239](https://github.com/CMTA/CMTAT/issues/239)
- Use calldata instead of memory [#224](https://github.com/CMTA/CMTAT/issues/224)
- Upgrade OpenZeppelin to the version [v.5.0.0](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.0)

## 2.3.1-rc.0 - 2023-09-25

The modifications between the version v2.3.0 and this version are not audited !!!

This version contains breaking changes with the version v2.3.0.

### Summary
**Architecture**
- The directory `mandatory` is renamed in `core` ([#222](https://github.com/CMTA/CMTAT/pull/222))
- The directory `optional` is renamed in `extensions` ([#222](https://github.com/CMTA/CMTAT/pull/222))
- Creation of a directory `controllers` which for the moment contains only the ValidationModule ([#222](https://github.com/CMTA/CMTAT/pull/222))
- Rename contract and init function for `ERC20BurnModule`, `ERC20MintModule`, `ERC20SnapshotModule` to clearly indicate the inheritance from ERC20 interface ([#226](https://github.com/CMTA/CMTAT/pull/226))

**Gas optimization**

- Add a batch version for the burn, mint and transfer functions (see [#51](https://github.com/CMTA/CMTAT/pull/51))
- Use custom error instead of string error message ([#217](https://github.com/CMTA/CMTAT/pull/217))

See [Defining Industry Standards for Custom Error Messages](https://blog.openzeppelin.com/defining-industry-standards-for-custom-error-messages-to-improve-the-web3-developer-experience)

**Other**

- Add ERC20 decimals as an argument of the initialize function ([#213](https://github.com/CMTA/CMTAT/pull/213))
  Until now, the number of decimal was set inside the code to the value 0
  This release changes this behavior to use instead a parameter supplied by the deployer inside the function initialize.
- Add a constant VERSION to indicate the current version of the token ([#229](https://github.com/CMTA/CMTAT/pull/229))
- Implement an alternative to the kill function ([#221](https://github.com/CMTA/CMTAT/pull/221))

The alternative function is the function `deactivateContract` inside the PauseModule, to deactivate the contract. This function set a boolean state variable `isDeactivated` to true and puts the contract in the pause state. The function `unpause`is updated to revert if the previous variable is set to true, thus the contract is in the pause state "forever".

The consequences are the following:

In standalone mode, this operation is irreversible, it is not possible to rollback.

With a proxy, it is still possible to rollback by deploying a new implementation.

**Tools**

- Update the Solidity version to 0.8.20, which is a requirement for the new OpenZeppelin version (5.0.0)
- Run tests with Hardhat instead of Truffle since Truffle does not support custom errors ([#217](https://github.com/CMTA/CMTAT/pull/51))
- Update OpenZeppelin to the version [v5.0.0-rc.0](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.0-rc.0)

**Security**
- Add new control on the DEFAULT_ADMIN_ROLE by inheriting `AccessControlDefaultAdminRules` ([#220](https://github.com/CMTA/CMTAT/pull/220))
This contract implements the following risk mitigations on top of [AccessControl](https://docs.openzeppelin.com/contracts/4.x/api/access#AccessControl):

Only one account holds the DEFAULT_ADMIN_ROLE since deployment until it’s potentially renounced.

Enforces a 2-step process to transfer the DEFAULT_ADMIN_ROLE to another account.

Enforces a configurable delay between the two steps, with the ability to cancel before the transfer is accepted.

- Add a function `transferadminshipDirectly` ([#226](https://github.com/CMTA/CMTAT/pull/226))
- Remove the module `OnlyDelegateCallModule` since it was used to protect the function `kill`, which has been removed in this version ([#221](https://github.com/CMTA/CMTAT/pull/221)).

## 2.3.0 - 2023-06-09

- Add Truffle CI workflow (Contributor: [diego-G](https://github.com/diego-G) / [21.co](https://github.com/amun))
- Add Truffle plugin [eth-gas-reporter](https://github.com/cgewecke/eth-gas-reporter)
- Add security policy

## 2.3.0-rc.0 - 2023-05-15

> The release 2.3-rc.0 is a *release candidate* before performing an official release 2.3

The release 2.3-rc.0 contains mainly the different fixes and improvements related to the audit performed on the version 2.2.

**Documentation**

- Update the documentation for the release
- Add slither & coverage reports 
- Install hardhat in order to use the solidity-coverage plugin

**General modifications**

- Rename contract CreditEvents to CreditEventsModule([pull/168](https://github.com/CMTA/CMTAT/pull/168))

- DebtBaseModule: the function `setDebt`takes an argument of type `DebtBase`(struct) instead of individual parameters to avoid issues with some compilers ([pull/175](https://github.com/CMTA/CMTAT/pull/175)).

- The interfaces ERC1404 & ERC1404Wrapper were renamed in IEIP1404 & EIP1404Wrapper since the proposition of standard ERC/EIP 1404 have never been approved ([pull/166](https://github.com/CMTA/CMTAT/pull/166)).

- Improve rule engine architecture: the RuleEngine to be used with the CMTAT has to implement the interface IEIP1404Wrapper ([pull/166](https://github.com/CMTA/CMTAT/pull/166))

It is no longer necessary to implement the interface RuleEngine, which was moved inside the mock directory

- When a contract is deployed, the admin address put in parameter has to be different from zero ([pull/162](https://github.com/CMTA/CMTAT/pull/162)).
- Remove snapshot module from default import since the snapshotModule is not audited ([pull/163](https://github.com/CMTA/CMTAT/pull/163))

**Audit report**

This version also includes improvements suggested by the audit report, addressing the following findings:

- CMTAT deployement ([pull/152](https://github.com/CMTA/CMTAT/pull/152)).

CVF-2: Create two main contracts: one for a deployment with a proxy, and one for a standalone deployment 

- ValidationModule & EnforcementModule ([pull/153](https://github.com/CMTA/CMTAT/pull/153))

CVF-1: The control was made in CMTAT.sol. We have moved this inside the ValidationModule

CVF-3 :  return a defined error message if the rule engine is not set.

 CVF-20: defined two different messages to indicate which address is frozen

 CVF-29:  defined a list of valid restriction code in ERC1404Wrapper

- Access Control ([pull/154](https://github.com/CMTA/CMTAT/pull/154))

CVF-10: override the function hasRole to give all roles to the default admin

CVF-11: remove the function transferContractControl

- Burn ([pull/155](https://github.com/CMTA/CMTAT/pull/155))

CVF-5: add a reason argument in the function + event as recommended

**Other**

CVF-4, CVF-13, CVF-18,  CVF-23: CVF related to events ([pull/159](https://github.com/CMTA/CMTAT/pull/159))

CVF-14: ValidationModule: Move the return statement inside the else branch as recommended ([pull/157](https://github.com/CMTA/CMTAT/pull/157))

CVF-16, CVF-17, CVF-19, CVF-22, CVF-25: related to events [(pull/158)](https://github.com/CMTA/CMTAT/pull/158)

CVF-21: remove the redundant part in the path ([pull/156](https://github.com/CMTA/CMTAT/pull/156))

## 2.2 - 2023-01-22

This version is not audited

This version contains breaking changes with the version 2.1.

**OpenZeppelin**

Updated OpenZeppelin contracts upgradeable to the version v4.8.1, precisely this [commit](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/commit/7ec6d2a3117eb3487a5f9029203e80ceb89bd984).

**Modules**

- Add the module Debt ([pull/118](https://github.com/CMTA/CMTAT/pull/118), [pull/141](https://github.com/CMTA/CMTAT/pull/141) ) 
- Add the module CreditEvents ([pull/135](https://github.com/CMTA/CMTAT/pull/135))
- SnapshotModule: use a sorted array instead of an unsorted array as suggested in the audit report ([pull/123](https://github.com/CMTA/CMTAT/pull/123))
- baseModule: add field information & flag ([pull/134](https://github.com/CMTA/CMTAT/pull/134))
- Access Control ([pull/130](https://github.com/CMTA/CMTAT/pull/130)):
  - Move `AuthorizationModule` from wrapper/optional to security
  - Move the different calls  of `grantRole`inside of the function  `AuthorizationModule_init_unchained`
  - Add a function `transferAdminship` in AuthorizationModule

- Improve and update tests of the different modules

**Audit report**

This version also includes improvements suggested by the audit report, addressing the following findings:

- SnapshotModule / CVF-3, CVF-8, CVF-13, CVF-17: [pull/123](https://github.com/CMTA/CMTAT/pull/123)
- CVF-21: change the type of the Event `RuleEngineSet` to `IRuleEngine`
- CVF-24, CVF-25, CVF-26: no change in the code, but a comment was added to explain the requirement.
- CVF-28: call to the `Validation_init_unchained` function in `__CMTAT_init`
- CVF-54: add the reason parameter in events `Freeze` and `Unfreeze`

## 2.1 - 2022-12-16

This version is not audited

This version contains breaking changes with the version 2.0.

- BurnModule

  - Replace the function *burnFrom* by the function *forceBurn* to permit the issuer (BURNER_ROLE) to burn tokens.
  - The versions CMTAT 1.0 and 2.0 do not strictly respect the CMTAT specification because you can only burn tokens if the sender (with the BURNER_ROLE) has the allowance on the tokens.
  - CMTAT 2.0 does not strictly respect the CMTAT specification because you can not force transfer or make an equivalent operation (burn tokens, then mint tokens to a new address).
- Proxy
  - Add a boolean to indicate if the contract is deployed with or without a proxy. 
  - Add a call to the function *disableInitializers* to prevent the implementation contract from being used.
  - Add a protection on the function kill by adding the module *OnlyDelegateCallModule*.

Others changes

- Proxy

  - Add initializers function in all contracts when they miss.

  - Add storage gaps in all contracts when they miss.

- OpenZeppelin
  - Updated OpenZeppelin contracts upgradeable to the version v4.8.0, precisely this [commit](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/tree/65420cb9c943c32eb7e8c9da60183a413d90067a).

  - Replace *setupRole* (deprecated) by *grantRole* in the function *CMTAT_init_unchained*.
- Improve the modularity of the architecture

  - Separate internal implementation from wrappers.
  - Separate mandatory and optional modules.
  - Move the BaseModule inside the mandatory directory.
  - Separate ERC20 functions from BaseModule by creating a specific module ERC20BaseModule.
  - Move the functions kill, setTokenId, setTerms from CMTAT.sol to BaseModule.
  - Move the functions pause & unpause  from CMTAT.sol to PauseModule.
  - Move the functions freeze & unfreeze from CMTAT.sol to EnforcementModule.
- Improve tests and their documentation of AuthorizationModule, BaseModule, BurnModule, EnforcementModule, MintModule and ValidationModule.

This version also includes improvements suggested by the audit report, addressing the following findings:

- CVF-2, CVF-46, CVF-49, CVF-53, CVF-57, CVF-60, CVF-62:  indicate the OpenZeppelin version in the file USAGE.md ([Commit](https://github.com/CMTA/CMTAT/commit/c0e257671144cf87bd33f241b3e208cfc374e45c)).

- CVF-29: perform a call to the *ERC165_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/3ade86b3c18857ff87a37e910f8855552d1a1065)).

- CVF-30: call *ERC20_init_unchained* before *Base_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/b3a96c917be7386a17bb170e2f9d90fabd3caffb)).
- CVF-35: specify which base contract is called instead of using the keyword *super* ([commit 1](https://github.com/CMTA/CMTAT/commit/38ec85df464fc8162e9214b2d308170d2de2d4fb), [commit 2](https://github.com/CMTA/CMTAT/commit/a6a8ca1bc0b974d0d1d63bc0f42e112d5f243b19)).

- CVF-47: define the functions *PauseModule_init* & *PauseModule_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/7a2735bec1d1dc1192f48303c8ce21f001747466)).
- CVF-51: define the functions *Authorization_init* & *Authorization_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/7a2735bec1d1dc1192f48303c8ce21f001747466)).
- CVF 52: move the mint functionality inside the MintModule ([commit](https://github.com/CMTA/CMTAT/commit/1a620f1f0ab29e2d2e1e3c6471c24c882d5c562d)).
- CVF-61: second part, define the functions *BurnModule_init* & *BurnModule_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/7a2735bec1d1dc1192f48303c8ce21f001747466)).

## 2.0 - 2022-11-04

This version is not fully ready to be used with a proxy, see issues [58](https://github.com/CMTA/CMTAT/issues/58) and [66](https://github.com/CMTA/CMTAT/issues/66)

This version contains breaking changes with the version 1.0

- Updated OpenZeppelin contracts upgradeable to the version v4.7.3, precisely this [commit](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/commit/0a2cb9a445c365870ed7a8ab461b12acf3e27d63).
- Solidity version updated to `^0.8.17`.
- Updated all libraries in package.json, exception for eth-sig-util which has not been updated.
- Set the `trustedForwarder` as immutable to be compatible with OpenZeppelin ([commit](https://github.com/CMTA/CMTAT/commit/56004748744448dac9faa089ef1e8ab5e8cc6d5c))
- Each test is performed with and without a proxy
  ([commit](https://github.com/CMTA/CMTAT/commit/de3596f4c6b32a9f9614b038e6db7ddddadbfb40)).
- Improved documentation by adding a summary of the audit, a description
  of the access control, an UML diagram of the project.

This version also includes improvements suggested by the audit report,
addressing the following findings:

- CVF-7, CVF-9 and CVF-10: removed useless return value in
  `_unscheduleSnapshot`, `_rescheduleSnapshot`, `_scheduleSnapshot`
  ([commit CVF-7](https://github.com/CMTA/CMTAT/commit/ff0deee3c7d978ef39ac5eb240f428888b3963d5), [commit CVF-9](https://github.com/CMTA/CMTAT/commit/b8148542b3812f8b0133d971cf82dc854e5fcebc), [commit CVF-10](https://github.com/CMTA/CMTAT/commit/1ea4a2ddf2215d98d4ea7c4fca5fe1304a6aa517)).
- CVF-27, 48, 55: used an `enum` to store the restriction code ([commit](https://github.com/CMTA/CMTAT/commit/4a8246dcb16dedcab7380ecc55eb38643355c76e)).
- CVF-40: defined event for `setTokenId` and `setTerms` ([commit](https://github.com/CMTA/CMTAT/commit/d845a97490a02f3f2284060a6a763f266f4f9ae7)).
- Fix CVF-56: renamed message for the constant`TEXT_TRANSFER_REJECTED_FROZEN` ([commit](https://github.com/CMTA/CMTAT/commit/6b16e738b613679876a8f465e78171bd27185060)).
- CVF-66, CVF-69, CVF-70, CVF-72, which created two new interfaces:`IERC1404` and `IERC1404Wrapper` ([commit](https://github.com/CMTA/CMTAT/commit/62c946b654f05b581c7774eda41c67ca9b10e3bf)).


## 1.0 - 2021-10-05

- Added CMTAT equity token core functionalities 
- Added support for OpenGSN gasless transactions
- Added support for proxy deployment
- Added ABDK security audit report
- Added initial API documentation

## 0.1 - 2019-11-20

- Legacy CMTA20 contract
