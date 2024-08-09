# Usage instructions

The instructions below have been tested on Ubuntu 20.04.5 LTS.

## Dependencies

The toolchain includes the following components, where the versions
are the latest ones that we tested: 

- npm 10.2.5
- Hardhat ^2.22.7
- Solidity 0.8.26 (via solc-js)
- Node 20.5.0
- OpenZeppelin
  - OpenZeppelin Contracts Upgradeable (submodule) [v5.0.2](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.2)
  - OpenZeppelin Contracts (Node.js module) [v5.0.2](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.0.2) 
    - Reason n°1: libraries and interfaces are no longer available inside the upgradeable version since the version v5.0.0.
    - Reason n°2: It is not installed as a github submodule because it will create conflicts with the imports inside OpenZeppelin which use the Node.js version.


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
