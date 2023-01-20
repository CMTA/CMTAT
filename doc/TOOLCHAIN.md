# TOOLCHAIN

## Node.JS  package

This part describe the list of libraries present in the file `package.json`.

### Dev

This section concerns the packages installed in the section `devDependencies` of package.json

#### Test

**[Chai](https://www.chaijs.com/)**
Library used for the tests

**[Coveralls](https://coveralls.io/)**
It is used to perform a code coverage

#### Truffle

**[Truffle](https://trufflesuite.com/)**
A development environment, testing framework and asset pipeline for blockchains using the Ethereum Virtual Machine (EVM).

**[Truffle Flattener](https://www.npmjs.com/package/truffle-flattener)**
Concats solidity files from Truffle projects with all of their dependencies.

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

**[Eth-Sig-Util](https://www.npmjs.com/package/ethereumjs-wallet)**
A collection of Ethereum signing functions. 

Warning :  
* Deprecated in favor of : [@metamask/eth-sig-util](https://github.com/MetaMask/eth-sig-util)
* It was not possible to use the new version of the library because the test "MetaTxModule.test.js" doesn't work with this one. The check of the signature fails.

**[solc](https://github.com/ethereum/solc-js)**
JavaScript bindings for the Solidity compiler.

**[Web3](https://github.com/web3/web3.js)**
Ethereum JavaScript API.

#### Others

**[dotenv](https://www.npmjs.com/package/dotenv)**
Loads environment variables from a .env file 

### Production 

This section concerns the packages installed in the section `dependencies` of package.json

**[ethereumjs-wallet](https://www.npmjs.com/package/ethereumjs-wallet)**
A wallet implementation

## Submodule

**[OpenZeppelin Contracts Upgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/)**
Upgradeable variant of OpenZeppelin Contracts, meant for use in upgradeable contracts.
The version of the library used is available in the file [USAGE.md](./USAGE.md)

Warning: 
- Submodules are not automatically updated when the host repository is updated.  
- Only update the module to a specific version, not an intermediary commit.



## Generate documentation

**[sol2uml](https://github.com/naddison36/sol2uml)** 
Generate UML for smart contracts
`
sol2uml ./contracts
`



### Surya

Link: https://github.com/ConsenSys/surya

### Graph (CFG)

- Full

```bash
npx surya graph -i contracts/**/*.sol | dot -Tpng > surya_graph_full.png
```

- Only the CMTAT

```bash
npx surya graph contracts/CMTAT.sol | dot -Tpng > surya_graph_cmtat.png
```



#### Inheritance

- Full 

```bash
npx surya inheritance contracts/CMTAT.sol -i | dot -Tpng > surya_inheritance_all_dot.png
```

- Only the CMTAT

```bash
npx surya inheritance contracts/CMTAT.sol | dot -Tpng > surya_inheritance_cmtat_dot.png
```

#### Generate report

- Full

```bash
npx surya mdreport -i surya_report.md contracts/CMTAT.sol  
```

In the report, the path for the different files are indicated in aboslute. You have to remove the part which correspond to your local filesystem.

- Only the CMTAT

```bash
npx surya mdreport surya_report.md contracts/CMTAT.sol  
```



### Solgraph

Link : https://github.com/raineorshine/solgraph

Generates a [DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)) graph that visualizes function control flow of a Solidity contract and highlights potential security vulnerabilities.

Solpgraph is less good that slither because it does not resolve automatically the inheritance

```bash
npx solgraph contracts/CMTAT.sol > solgraph_CMTAT.dot
```



```bash
dot -Tpng solgraph_CMTAT.dot -o solgraph_dot.png
```









