# Usage instructions

The different tools have been installed and tested on a computer with the following properties :  
`Distributor ID:	Ubuntu`  
`Description:	Ubuntu 20.04.5 LTS`  
`Release:	20.04`  
`Codename:	focal`

## Main Toolchain

The main toolchain is composed of theses libraries. The number after the library name is the version number.
- npm 8.19.2
- Truffle v5.5.31 (core: 5.5.31)
- Ganache v7.4.3
- Solidity - 0.8.4 (solc-js)
- Node v16.17.0
- Web3.js v1.7.4

## Installation

- Clone the project with the option `--recurse-submodules` to get the submodules like the library `openzeppelin contracts upgradeable`
Example :  
`git clone git@github.com:CMTA/CMTAT.git  --recurse-submodules`  
Or you can install them later with these following commands:  
`git submodule init
git submodule update`

- To manage several version of Node.js on your machine, you can use the tool `nvm` available here : [website](https://github.com/nvm-sh/nvm).  
Once the tool is installed, you can by example install the version 16.17.0 of Node.js with the following command :    
`nvm install 16.17.0`.   
The version of Node.js to install is indicated in the section *Main Toolchain*

- To install the node modules, run the following command at the root of the project :  
`npm install`

- Installation global of truffle :  
`npm install -g truffle`  
The official documentation is available here : [website](https://trufflesuite.com/docs/truffle/getting-started/installation/)


## Testing

Tests are written in JavaScript (Node.js package) and run with Truffle through the command truffle test. The test suite could be correctly built and run with the toolchain described in the section "Main Toolchain".

Truffle has to be installed globally or used with the npx command. Everything else needed is installed through npm install with the right versions.

Please see the Truffle JavaScript tests documentation for more information about the writing and running of Truffle tests.


## Coding rules

### Code Style
*Javascript*  
The code style for Javascript files is ensured by Eslint.
If you write code, please run this following command :  
`eslint .,
eslint . --fix`    
*Solidity*  
The code style for Solidity files is ensured by Ethlint (Solium)  
`solium -d .`  
`solium -d . --fix`

## Kown bugs
The coverage with the library *solidity-coverage* does not work anymore.  
See : [website](https://github.com/sc-forks/solidity-coverage/issues/694) 
