# TOOLCHAIN

## Node.JS  package
This part describe the list of libraries present in the file `package.json`.

### Dev
This section concerns the packages installed in the section `devDependencies` of package.json

#### Test

**Chai**
[Website](https://www.chaijs.com/)  
Library used for the tests

**Coveralls**
[Website](https://coveralls.io/)
It is used to perform a code coverage

#### Truffle
**Truffle**
[Website](https://trufflesuite.com/)
A development environment, testing framework and asset pipeline for blockchains using the Ethereum Virtual Machine (EVM).

**Truffle Flattener**
[Website](https://www.npmjs.com/package/truffle-flattener)
Concats solidity files from Truffle projects with all of their dependencies.

#### Linter

**eslint**
[Website](https://eslint.org/)
Static analyzer of the code

**eslint-config-standard**
Shareable configs are designed to work with the extends feature of .eslintrc files.
[Website](https://github.com/standard/eslint-config-standard)

**eslint-plugin-import**
[Website](https://github.com/import-js/eslint-plugin-import)
This plugin intends to support linting of ES2015+ (ES6+) import/export syntax, and prevent issues with misspelling of file paths and import names. 

**eslint-plugin-node**
[Website](https://github.com/mysticatea/eslint-plugin-node)
Additional ESLint's rules for Node.js

**eslint-plugin-promise**
[Website](https://github.com/eslint-community/eslint-plugin-promise)
Enforce best practices for JavaScript promises.

**Ethlint**
[Website](https://github.com/duaraghav8/Ethlint)
Ethlint analyzes your Solidity code for style & security issues and fixes them.

#### Ethereum / Solidity
**ethereumjs-util**
[Website](https://www.npmjs.com/package/ethereumjs-util)
It contains a collection of utility functions for Ethereum (account, address, signature, ...)

**ethjs-abi**
[Website](https://github.com/ethjs/ethjs-abi)
Warning : indicated as experimental package on 22.08.2022
Encode and decode method and event from the smart contract abi.

**Eth-Sig-Util**
A small collection of ethereum signing functions.
[Website](https://www.npmjs.com/package/ethereumjs-wallet)
Warning : 
- Deprecated in favor of '@metamask/eth-sig-util'. [Website](https://github.com/MetaMask/eth-sig-util)
- It was not possible to use the new version of the library because the test "MetaTxModule.test.js" doesn't work with this one. The check of the signature fails.

**solc**
[Website](https://github.com/ethereum/solc-js)
JavaScript bindings for the Solidity compiler.

**Web3**
Ethereum JavaScript API
[Website](https://github.com/web3/web3.js)

#### Others

**dotenv**
[Website](https://www.npmjs.com/package/dotenv)
Loads environment variables from a .env file 

### Production 

This section concerns the packages installed in the section `dependencies` of package.json

**ethereumjs-wallet**
A wallet implementation
[Website](https://www.npmjs.com/package/ethereumjs-wallet)


**@openzeppelin/contracts**
Libraries of smart contracts
[Website](https://www.openzeppelin.com/contracts)

## UML

**sol2uml** 
Generate UML for smart contracts
[Website](https://github.com/naddison36/sol2uml)
`
sol2uml ./contracts
`
