# Usage instructions

The instructions below have been tested on Ubuntu 20.04.5 LTS.

## Tool and versions

The main toolchain is composed of these components, where the versions are the latest ones we tested: 

- npm 8.19.2
- Truffle 5.5.31 (core: 5.5.31)
- Ganache 7.4.3
- Solidity 0.8.4 (via solc-js)
- Node 16.17.0
- Web3.js 1.7.4

## Installation

Clone the git repository, with the option `--recurse-submodules` to fetch the submodules:

`git clone git@github.com:CMTA/CMTAT.git  --recurse-submodules`  

To manage multiple version of Node.js on your machine, you can use [`nvm`](https://github.com/nvm-sh/nvm).  
Once `nvm` is installed, you can by example install the version 16.17.0 of Node.js with the following command:

`nvm install 16.17.0`

To install the node modules required, run the following command at the root of the project:

`npm install`

For truffle you can use the installed version in the node modules by using the command `npx`, for example
`npx truffle`
We recommand this way to do to have the same version as the one used to test the project.

It is also possible to install globally truffle :
(https://trufflesuite.com/docs/truffle/getting-started/installation/) on your system:
`npm install -g truffle` 
You can read the official [documentation](https://trufflesuite.com/docs/truffle/getting-started/installation/) for more information.


## Testing

Tests are written in JavaScript and run with Truffle with the command 

Package locale : `npx truffle test`
Installation globable :  `truffle test`

## Code style guidelines

We use linters to ensure consistent coding style. If you contribute code, please run this following command: 

For JavaScript:
```
npm run-script lint .
npm run-script lint:fix . 
```
   
For Solidity:
```
npm run-script lint:sol  
npm run-script lint:sol:fix
```

## Known bugs
The coverage with the library *solidity-coverage* [does not work anymore](https://github.com/sc-forks/solidity-coverage/issues/694).
