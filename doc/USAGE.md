# Usage instructions

The instructions below have been tested on Ubuntu 20.04.5 LTS.

## Dependencies

The toolchain includes the following components, where the versions
are the latest ones that we tested: 

- npm 8.19.2
- Hardhat-web3 2.0.0
- *Truffle 5.9.3 [depreciated]*
- Solidity 0.8.17 (via solc-js)
- Node 16.17.0
- Web3.js 1.9.0
- OpenZeppelin Contracts Upgradeable (submodule) [v5.0.0-rc.0](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.0-rc.0)

## Installation

- Clone the repository

Clone the git repository, with the option `--recurse-submodules` to fetch the submodules:

`git clone git@github.com:CMTA/CMTAT.git  --recurse-submodules`  

- Node.js version

We recommend to install the [Node Version Manager `nvm`](https://github.com/nvm-sh/nvm) to manage multiple versions of Node.js on your machine. You can then, for example, install the version 16.17.0 of Node.js with the following command: `nvm install 16.17.0`

The file [.nvmrc](../.nvmrc) at the root of the project set the Node.js version. `nvm use`will automatically use this version if no version is supplied on the command line.

- node modules

To install the node modules required by CMTAT, run the following command at the root of the project:

`npm install`



### Hardhat

> Since the version v2.3.1, Hardhat is our main development tool and replace Truffle. The reason behind this change is the fact that Truffle does not support custom errors for testing.

To use Hardhat, the recommended way is to use the version installed as
part of the node modules, via the `npx` command:

`npx hardhat`

Alternatively, you can install Truffle [globally](https://trufflesuite.com/docs/truffle/getting-started/installation/):

`npm install -g hardhat` 

See Hardhat's official [documentation](https://hardhat.org) for more information.

### Truffle [partially depreciated]

> Truffle can still be used to compile the contracts but you can no longer use it to run the tests.

To use Truffle, the recommended way is to use the version installed as
part of the node modules, via the `npx` command:

`npx truffle`

Alternatively, you can install Truffle [globally](https://trufflesuite.com/docs/truffle/getting-started/installation/):

`npm install -g truffle` 

See Truffle's official [documentation](https://trufflesuite.com/docs/truffle/getting-started/installation/) for more information.



## Contract size

You can get the size of the contract by running the following commands.

- Compile the contracts:

```bash
npx truffle compile
npx hardhat compile
```

- Run the script:

```bash
npm run-script size
npm run-script hardhat:size
```

The script calls the plugin `truffle-contract-size` for Truffle or [hardhat-contract-sizer](https://www.npmjs.com/package/hardhat-contract-sizer) with Hardhat.

## Testing

Tests are written in JavaScript by using [web3js](https://web3js.readthedocs.io/en/v1.10.0/) and run **only** with Hardhat as follows:

`npx hardhat test`

To use the global hardhat install, use instead `hardhat test`.

Please see the Truffle [JavaScript tests documentation](https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript) for more information about the writing and running of Truffle tests since the tests were originally written for Truffle.



[**Depreciated** since the version v2.3.21]

> Since the version v2.3.1, it is no longer possible to run tests with Truffle.
>
> Truffle does not support custom errors for testing.

Tests are written in JavaScript and run with Truffle as follows:

`npx truffle test`

To use the global Truffle install, use instead `truffle test`.

Please see the Truffle [JavaScript tests documentation](https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript) for more information about the writing and running of Truffle tests.


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
