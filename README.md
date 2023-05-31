# CMTA Token 

[TOC]

## Introduction

The CMTA token (CMTAT) is a framework enabling the tokenization of securities in compliance with Swiss law.

The CMTAT is an open standard from the [Capital Markets and Technology Association](http://www.cmta.ch/) (CMTA), and the product of collaborative work by leading organizations in the Swiss finance and technology ecosystem.

The present repository provides CMTA's reference implementation of CMTAT for Ethereum, as an ERC-20 compatible token.

The CMTAT is developed by a working group of CMTA's Technical Committee that includes members from Atpar, Bitcoin Suisse, Blockchain Innovation Group, Hypothekarbank Lenzburg, Lenz & Staehelin, Metaco, Mt Pelerin, SEBA, Swissquote, Sygnum, Taurus and Tezos Foundation. The design and security of the CMTAT was supported by ABDK, a leading team in smart contract security.

The preferred way to receive comments is through the GitHub issue tracker.  Private comments and questions can be sent to the CMTA secretariat at <a href="mailto:admin@cmta.ch">admin@cmta.ch</a>. For security matters, please see [SECURITY.md](./SECURITY.MD).

## Functionality

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

To use the CMTAT, we recommend that you use the latest audited version, from the [Releases](https://github.com/CMTA/CMTAT/releases) page.

You may modify the token code by adding, removing, or modifying features. However, the mandatory modules must remain in place for compliance with Swiss law.

### Deployment mode (With A Proxy)

#### With A proxy

The CMTAT supports deployment via a proxy contract.  Furthermore, using a proxy permits to upgrade the contract, using a standard proxy upgrade pattern.

The contract version to use as an implementation is the `CMTAT_PROXY`.

Please see the OpenZeppelin [upgradeable contracts documentation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable) for more information about the proxy requirements applied to the contract.

Please see the OpenZeppelin [Upgrades plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for more information about upgrades plugins in general.

Note that deployment via a proxy is not mandatory, but recommended by CMTA.

## Modules

Here the list of the differents modules with the links towards the documentation and the main file.

### Mandatory

| Name              | Documentation                                                | Main File                                                    |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| BaseModule        | [base.md](doc/modules/presentation/mandatory/base.md)        | [BaseModule.sol](./contracts/modules/wrapper/mandatory/BaseModule.sol) |
| BurnModule        | [burn.md](doc/modules/presentation/mandatory/burn.md)        | [BurnModule.sol](./contracts/modules/wrapper/mandatory/BurnModule.sol) |
| ERC20BaseModule   | [erc20base.md](doc/modules/presentation/mandatory/erc20base.md) | [ERC20BaseModule.sol](./contracts/modules/wrapper/mandatory/ERC20BaseModule.sol) |
| MintModule        | [mint.md](doc/modules/presentation/mandatory/mint.md)        | [MintModule.sol](./contracts/modules/wrapper/mandatory/MintModule.sol) |
| PauseModule       | [pause.md](doc/modules/presentation/mandatory/pause.md)      | [PauseModule.sol](./contracts/modules/wrapper/mandatory/PauseModule.sol) |

### Optional

| Name              | Documentation                                                | Main File                                                    |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ValidationModule  | [validation.md](doc/modules/presentation/optional/validation.md) | [ValidationModule.sol](./contracts/modules/wrapper/optional/ValidationModule.sol) |

*not imported by default

### Security

| Name                   | Documentation                                                | Main File                                                    |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| AuthorizationModule    | [authorization.md](./doc/modules/presentation/security/authorization.md) | [AuthorizationModule.sol](./contracts/modules/security/AuthorizationModule.sol) |

## Security

### Vulnerability disclosure

Please see [SECURITY.md](./SECURITY.MD).


### Module

See the Section Modules/Security.

The Access Control is managed inside the module `AuthorizationModule`.

### Audit

The contracts have been audited by [ABDKConsulting](https://www.abdk.consulting/), a globally recognized firm specialized in smart contracts' security.

#### First audit - September 2021

Fixes of security issues discovered by the initial audit were reviewed by ABDK and confirmed to be effective, as certified by the [report released](doc/audits/ABDK-CMTAT-audit-20210910.pdf) on September 10, 2021, covering [version c3afd7b](https://github.com/CMTA/CMTAT/tree/c3afd7b4a2ade160c9b581adb7a44896bfc7aaea) of the contracts.
Version [1.0](https://github.com/CMTA/CMTAT/releases/tag/1.0) includes additional fixes of minor issues, compared to the version retested.

A summary of all fixes and decisions taken is available in the file [CMTAT-Audit-20210910-summary.pdf](doc/audits/CMTAT-Audit-20210910-summary.pdf) 

#### Second audit - March 2023

The second audit was performed by ABDK on the version [2.2](https://github.com/CMTA/CMTAT/releases/tag/2.2).

The release 2.3 contains the different fixes and improvements related to this audit.

The temporary report is available in the file [Taurus. Audit 3.1. Collected Issues.ods](doc/audits/Taurus.Audit3.1.CollectedIssues.ods). 

### Tools

You will find the report performed with [Slither](https://github.com/crytic/slither) in the file [slither-report.md](doc/audits/tools/slither-report.md) 

### Test

- You will find a summary of all automatic tests in the file [test.pdf](doc/general/test/test.pdf) 
- A code coverage is available in the file [index.html](doc/general/test/coverage/index.html)

> For information, we do not perform tests on the internal functions `init` of the different modules.

### Remarks

As with any token contract, access to the owner key must be adequately restricted.
Likewise, access to the proxy contract must be restricted and seggregated from the token contract.

## Documentation

Here a summary of the main documentation

| Document                          | Link/Files                                                 |
| --------------------------------- | ---------------------------------------------------------- |
| Documentation of the modules API. | [doc/modules](doc/modules)                                 |
| Documentation on the toolchain    | [doc/TOOLCHAIN.md](doc/TOOLCHAIN.md)                       |
| How to use the project            | [doc/USAGE.md](doc/USAGE.md)                               |
| Project architecture              | [doc/general/architecture.md](doc/general/architecture.md) |

CMTA will release further documentation describing the CMTAT framework in a platform-agnostic way, and coveging legal aspects, see

-  [CMTA Token (CMTAT)](https://cmta.ch/standards/cmta-token-cmtat)
- [Standard for the tokenization of shares of Swiss corporations using the distributed ledger technology](https://cmta.ch/standards/standard-for-the-tokenization-of-shares-of-swiss-corporations-using-the-distributed-ledger-technology)

## Intellectual property

The code is copyright (c) Capital Market and Technology Association, 2018-2023, and is released under [Mozilla Public License 2.0](./LICENSE.md).
