# Usage instructions

The instructions below have been tested on Ubuntu 20.04.5 LTS.

## Dependencies

The toolchain includes the following components, where the versions
are the latest ones that we tested:

- npm 9.5.1
- Hardhat 2.19.1
- Solidity 0.8.17 (via solc-js)
- Node 18.16.0
- Web3.js 1.10.0
- OpenZeppelin Contracts Upgradeable (submodule) 4.8.1

## Installation

Clone the git repository, with the option `--recurse-submodules` to fetch the submodules:

`git clone git@github.com:CMTA/CMTAT.git  --recurse-submodules`

We recommend to install the [Node Version Manager `nvm`](https://github.com/nvm-sh/nvm) to manage multiple versions of Node.js on your machine. You can then, for example, install the version 16.17.0 of Node.js with the following command: `nvm install 16.17.0`

To install the node modules required by CMTAT, run the following command at the root of the project:

`npm install`

### Hardhat

To use Hardhat, the recommended way is to use the version installed as
part of the node modules, via the `npx` command:

`npx hardhat`

See Hardhat's official [documentation](https://hardhat.org/docs) for more information.

## Contract Size

You can get the size of the contract by running the following commands.

- Compile the contracts

```bash
npx hardhat compile
```

- Run the script

```bash
npm run-script size
```

The script calls the plugin `hardhat-contract-size`

## Testing

Tests are written in JavaScript and run with Hardhat as follows:

`npx hardhat test`

To use the global Hardhat install, use instead `hardhat test`.

Please see the Hardhat [Testing contracts](https://hardhat.org/hardhat-runner/docs/guides/test-contracts) for more information about the writing and running of Hardhat tests.

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
