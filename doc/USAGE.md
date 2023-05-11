# Usage instructions

The instructions below have been tested on Ubuntu 20.04.5 LTS.

## Dependencies

The toolchain includes the following components, where the versions
are the latest ones that we tested: 

- npm 8.19.2
- Truffle 5.8.3
- Solidity 0.8.17 (via solc-js)
- Node 16.17.0
- Web3.js 1.9.0
- OpenZeppelin Contracts Upgradeable (submodule) 4.8.1

Although present in the dependencies, Hardhat is not included in the toolchain since the project was mainly build with and for Truffle.

## Installation

Clone the git repository, with the option `--recurse-submodules` to fetch the submodules:

`git clone git@github.com:CMTA/CMTAT.git  --recurse-submodules`  

We recommend to install the [Node Version Manager `nvm`](https://github.com/nvm-sh/nvm) to manage multiple versions of Node.js on your machine. You can then, for example, install the version 16.17.0 of Node.js with the following command: `nvm install 16.17.0`

To install the node modules required by CMTAT, run the following command at the root of the project:

`npm install`

### Truffle

To use Truffle, the recommended way is to use the version installed as
part of the node modules, via the `npx` command:

`npx truffle`

Alternatively, you can install Truffle [globally](https://trufflesuite.com/docs/truffle/getting-started/installation/):

`npm install -g truffle` 

See Truffle's official [documentation](https://trufflesuite.com/docs/truffle/getting-started/installation/) for more information.

### Hardhat

Same principle as Truffle

```
npx hardhat
```



## Contract Size

You can get the size of the contract by running the following commands.

- Compile the contracts

```bash
npx truffle compile
```

- Run the script

```bash
npm run-script size
```

The script calls the plugin `truffle-contract-size`

## Testing

Tests are written in JavaScript and run with Truffle as follows:

`npx truffle test`

To use the global Truffle install, use instead `truffle test`.

Please see the Truffle [JavaScript tests documentation](https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript) for more information about the writing and running of Truffle tests.

If you try to run the tests with Hardhat, the tests related to the proxy and the SnapshotModule will not work.




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
