# TOOLCHAIN

[TOC]

## Node.JS  package

This part describe the list of libraries present in the file `package.json`.

### Dev

This section concerns the packages installed in the section `devDependencies` of package.json

#### Test

**[Chai](https://www.chaijs.com/)**
Library used for the tests

**[Coveralls](https://coveralls.io/)**
It is used to perform a code coverage

#### Nomiclabs - Hardhat

**[hardhat-truffle5](https://hardhat.org/hardhat-runner/plugins/nomiclabs-hardhat-truffle5)**

[Hardhat](https://hardhat.org/) plugin for integration with TruffleContract from Truffle 5. This allows tests and scripts written for Truffle to work with Hardhat.

**[hardhat-web3](https://hardhat.org/hardhat-runner/plugins/nomiclabs-hardhat-web3)**

This plugin integrates [Web3.js](https://github.com/ethereum/web3.js) `1.x` into [Hardhat](https://hardhat.org/).

**[hardhat-ethers](https://www.npmjs.com/package/@nomicfoundation/hardhat-ethers)**

[Hardhat](https://hardhat.org/) plugin for integration with [ethers.js](https://github.com/ethers-io/ethers.js/)

**[hardhat-contract-sizer](https://www.npmjs.com/package/hardhat-contract-sizer)**

Output Solidity contract sizes with Hardhat.

**[hardhat-gas-reporter](https://www.npmjs.com/package/hardhat-gas-reporter)**

[eth-gas-reporter](https://github.com/cgewecke/eth-gas-reporter) plugin for [hardhat](http://gethardhat.com/).

#### OpenZeppelin

**[openzeppelin/hardhat-upgrades](openzeppelin/hardhat-upgrades)**

This package adds functions to your Hardhat scripts so you can deploy and upgrade proxies for your contracts

**[openzeppelin/test-helpers](openzeppelin/test-helpers)**

Assertion library for Ethereum smart contract testing

#### Linter

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


#### Ethereum / Solidity

**[ethereumjs-util](https://www.npmjs.com/package/ethereumjs-util)**
Collection of utility functions for Ethereum (account, address,
signature, etc.).

**[ethjs-abi](https://github.com/ethjs/ethjs-abi)**
Encode and decode method and event from the smart contract ABI. Warning:
marked as experimental package on 22.08.2022.

**[eth-gas-reporter](https://www.npmjs.com/package/eth-gas-reporter)**

A Mocha reporter for Ethereum test suites (Truffle)

**[Eth-Sig-Util](https://www.npmjs.com/package/ethereumjs-wallet)**
A collection of Ethereum signing functions. 

Warning :  
* Deprecated in favor of : [@metamask/eth-sig-util](https://github.com/MetaMask/eth-sig-util)
* It was not possible to use the new version of the library because the test "MetaTxModule.test.js" doesn't work with this one. The check of the signature fails.

[keccak256](https://www.npmjs.com/package/keccak256)

A wrapper for the [`keccak`](https://www.npmjs.com/package/keccak) library to compute 256 bit keccak hash in JavaScript.

Use by `openzeppelin-contracts-upgradeable/test/helpers/eip712`imported in `MetaTxModuleCommon.js 

**[solc](https://github.com/ethereum/solc-js)**
JavaScript bindings for the Solidity compiler.

#### Documentation

**[sol2uml](https://github.com/naddison36/sol2uml)**

Generate UML for smart contracts

**[solidity-coverage](https://github.com/sc-forks/solidity-coverage/)**

Code coverage for Solidity smart-contracts

**[solidity-docgen](https://github.com/OpenZeppelin/solidity-docgen)**

Program that extracts documentation for a Solidity project.

**[Surya](https://github.com/ConsenSys/surya)**

Utility tool for smart contract systems.

#### solidity-coverage

#### Others

**[dotenv](https://www.npmjs.com/package/dotenv)**
Loads environment variables from a .env file 

### Production 

This section concerns the packages installed in the section `dependencies` of package.json



## Submodule

**[OpenZeppelin Contracts Upgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/)**
Upgradeable variant of OpenZeppelin Contracts, meant for use in upgradeable contracts.
The version of the library used is available in the file [USAGE.md](./USAGE.md)

Warning: 
- Submodules are not automatically updated when the host repository is updated.  
- Only update the module to a specific version, not an intermediary commit.



## Generate documentation

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
