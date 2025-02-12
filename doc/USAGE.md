# Usage instructions

The instructions below have been tested on Ubuntu 22.04.5 LTS.

[TOC]



## Main Dependencies

The toolchain includes the following components, where the versions
are the latest ones that we tested: 

### Smart contract

- Solidity 0.8.28 (via solc-js)
- OpenZeppelin Contracts (Node.js module) [v5.2.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.2.0) 
- OpenZeppelin Contracts Upgradeable (Node.js module) [v5.2.0](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.2)

### Tools

- Node 20.5.0

- npm 10.2.5
- Nomiclabs - Hardhat: ^2.22.7
  - **[hardhat-web3](https://hardhat.org/hardhat-runner/plugins/nomiclabs-hardhat-web3)**: This plugin integrates [Web3.js](https://github.com/ethereum/web3.js) `1.x` into [Hardhat](https://hardhat.org/).
  - **[hardhat-ethers](https://www.npmjs.com/package/@nomicfoundation/hardhat-ethers)**
  - [Hardhat](https://hardhat.org/) plugin for integration with [ethers.js](https://github.com/ethers-io/ethers.js/)
  - **[hardhat-contract-sizer](https://www.npmjs.com/package/hardhat-contract-sizer)**: Output Solidity contract sizes with Hardhat.
  - **[hardhat-gas-reporter](https://www.npmjs.com/package/hardhat-gas-reporter)**
  - [solidity-coverage](https://github.com/sc-forks/solidity-coverage): Hardhat plugin for solidity coverage


#### Submodule

Use inside Javascript tests

OpenZeppelin Contracts Upgradeable (submodule) [v5.2.0](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.2.0)
Upgradeable variant of OpenZeppelin Contracts, meant for use in upgradeable contracts.
The version of the library used is available in the file [USAGE.md](./USAGE.md)

Warning: 

- Submodules are not automatically updated when the host repository is updated.  
- Only update the module to a specific version, not an intermediary commit.


## Installation

- Clone the repository

Clone the git repository, with the option `--recurse-submodules` to fetch the submodules:

`git clone git@github.com:CMTA/CMTAT.git  --recurse-submodules`  

- Node.js version

We recommend to install the [Node Version Manager `nvm`](https://github.com/nvm-sh/nvm) to manage multiple versions of Node.js on your machine. You can then, for example, install the version 20.5.0 of Node.js with the following command: `nvm install 20.5.0`

The file [.nvmrc](../.nvmrc) at the root of the project set the Node.js version. `nvm use`will automatically use this version if no version is supplied on the command line.

- node modules

To install the node modules required by CMTAT, run the following command at the root of the project:

`npm install`



### Hardhat

> Since the [sunset of Truffle](https://consensys.io/blog/consensys-announces-the-sunset-of-truffle-and-ganache-and-new-hardhat) by Consensys ,Hardhat is our main development tool and replace Truffle. 

To use Hardhat, the recommended way is to use the version installed as
part of the node modules, via the `npx` command:

`npx hardhat`

Alternatively, you can install Hardhat [globally](https://hardhat.org/hardhat-runner/docs/getting-started):

`npm install -g hardhat` 

See Hardhat's official [documentation](https://hardhat.org) for more information.

### Truffle [depreciated]

Truffle is no longer supported since it has been sunset by Consensys, see [Consensys Announces the Sunset of Truffle and Ganache and New Hardhat Partnership](https://consensys.io/blog/consensys-announces-the-sunset-of-truffle-and-ganache-and-new-hardhat)

## Contract size

You can get the size of the contract by running the following commands.

- Compile the contracts:

```bash
npx hardhat compile
```

- Run the script:

```bash
npm run-script size
```

The script calls the plugin [hardhat-contract-sizer](https://www.npmjs.com/package/hardhat-contract-sizer) with Hardhat.

## Testing

Tests are written in JavaScript by using [web3js](https://web3js.readthedocs.io/en/v1.10.0/) and run **only** with Hardhat as follows:

`npx hardhat test`

To use the global hardhat install, use instead `hardhat test`.

Please see the Hardhat [documentation](https://hardhat.org/tutorial/testing-contracts) for more information about the writing and running of  Hardhat.


## Code style guidelines

We use linters to ensure consistent coding style. If you contribute code, please run this following command: 

For JavaScript:
```bash
npm run-script lint:js 
npm run-script lint:js:fix 
```

For Solidity:
```bash
npm run-script lint:sol  
npm run-script lint:sol:fix
```

### NodeJS toolchain

**[eslint](https://eslint.org/)**
JavaScript static analyzer, and the following plugins:

* **[eslint-config-standard](https://github.com/standard/eslint-config-standard)**
  Shareable configs designed to work with the extends feature of .eslintrc files.

* **[eslint-plugin-import](https://github.com/import-js/eslint-plugin-import)**
  Plugin to support linting of ES2015+ (ES6+) import/export syntax, and prevent issues with misspelling of file paths and import names. 

* **[eslint-plugin-node](https://github.com/mysticatea/eslint-plugin-node)**
  Additional ESLint's rules for Node.js

* **[eslint-plugin-promise](https://github.com/eslint-community/eslint-plugin-promise)**
  Enforcement best practices for JavaScript promises.

**[Ethlint](https://github.com/duaraghav8/Ethlint)**
Solidity static analyzer.

## Compilation with solc

**[solc](https://github.com/ethereum/solc-js)**
JavaScript bindings for the Solidity compiler.

```bash
solc --base-path . --include-path ./node_modules/ contracts/CMTAT_STANDALONE.sol
```

## Generate documentation

### NodeJS toolchain

**[sol2uml](https://github.com/naddison36/sol2uml)**

Generate UML for smart contracts

**[solidity-coverage](https://github.com/sc-forks/solidity-coverage/)**

Code coverage for Solidity smart-contracts

**[solidity-docgen](https://github.com/OpenZeppelin/solidity-docgen)**

Program that extracts documentation for a Solidity project.

**[Surya](https://github.com/ConsenSys/surya)**

Utility tool for smart contract systems.

### [sol2uml](https://github.com/naddison36/sol2uml)

Generate UML for smart contracts

You can generate UML for smart contracts by running the following command:

```bash
npm run-script uml
```

Warning:

From the version v2.3.0, this command is not working and generates the following error

> RangeError: Maximum call stack size exceeded

| Description                                                  | Command                                |
| ------------------------------------------------------------ | -------------------------------------- |
| Generate UML for all modules                                 | `npm run-script uml-all`               |
| Generate UML for the interfaces EIP1404                      | `npm run-script uml-i-eip1404`         |
| Generate UML for the contracts CMTAT_STANDALONE, CMTAT_PROXY && CMTAT_BASE | `npm run-script uml-partial`           |
| Generate UML for core modules                                | `npm run-script uml-modules-mandatory` |
| Generate UML for extensions modules                          | `npm run-script uml-modules-optional`  |
| Generate UML for security modules                            | `npm run-script uml-modules-security`  |
| Generate UML for mocks                                       | `npm run-script uml-mocks`             |



### [Surya](https://github.com/ConsenSys/surya)

To generate documentation with surya, you can call the three bash scripts in doc/script

| Task                 | Script                      | Command exemple                                              |
| -------------------- | --------------------------- | ------------------------------------------------------------ |
| Generate graph       | script_surya_graph.sh       | npx surya graph -i contracts/**/*.sol <br />npx surya graph contracts/modules/CMTAT_BASE.sol |
| Generate inheritance | script_surya_inheritance.sh | npx surya inheritance contracts/modules/CMTAT_BASE.sol -i <br />npx surya inheritance contracts/modules/CMTAT_BASE.sol |
| Generate report      | script_surya_report.sh      | npx surya mdreport -i surya_report.md contracts/modules/CMTAT_BASE.sol <br />npx surya mdreport surya_report.md contracts/modules/CMTAT_BASE.sol |

In the report, the path for the different files are indicated in absolute. You have to remove the part which correspond to your local filesystem.



### [Coverage](https://github.com/sc-forks/solidity-coverage/)

Code coverage for Solidity smart-contracts, installed as a hardhat plugin

```bash
npm run-script coverage
```



### [Slither](https://github.com/crytic/slither)

Slither is a Solidity static analysis framework written in Python3

```bash
slither .  --checklist --filter-paths "openzeppelin-contracts-upgradeable|openzeppelin-contracts|@openzeppelin|test" > slither-report.md
```

### [Mythril](https://github.com/Consensys/mythril)

- Standalone

```bash
myth analyze contracts/CMTAT_STANDALONE.sol --solc-json solc_setting.json > myth_standalone_report.md
```

- With proxy

```bash
myth analyze contracts/CMTAT_PROXY.sol --solc-json solc_setting.json > myth_proxy_report.md
```

File path for `solc` is configured in `solc_setting.json`



## Others NodeJS tools

This part describe the list of libraries present in the file `package.json`.

- **[Chai](https://www.chaijs.com/)**
  Library used for the tests

- **[openzeppelin/hardhat-upgrades](openzeppelin/hardhat-upgrades)**

This package adds functions to your Hardhat scripts so you can deploy and upgrade proxies for your contracts

- [keccak256](https://www.npmjs.com/package/keccak256)

A wrapper for the [`keccak`](https://www.npmjs.com/package/keccak) library to compute 256 bit keccak hash in JavaScript.

Use by `openzeppelin-contracts-upgradeable/test/helpers/eip712`imported in `MetaTxModuleCommon.js 

