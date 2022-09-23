# Usage instructions

## Main
To manage several version of Node.js on your machine, you can use the tool `nvm` avaialable here : [https://github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)

Installation of Node.JS, version 10.13.0
`nvm install 10.13.0`

Installation of truffle, version 5.3.8 :
`npm install -g truffle@5.3.8`
Warning : the installation of the specific version 5.3.8 can fail.

The offcial documentation is available here : https://trufflesuite.com/docs/truffle/getting-started/installation/

## Others

**sol2uml** 
Generate UML for smart contracts
Link : https://github.com/naddison36/sol2uml
`
nvm use 14
sol2uml ./contracts
`
The Node.JS version 14 is the minimal version.

## Node.JS  package
To install the nodes module, run the following command
`npm install`

## List
This part describe the list of libraries prsent in the file `package.json`.
### Dev
#### Test
**Chai**
Website : https://www.chaijs.com/
Library used for the tests

**Coveralls**
Website : https://coveralls.io/
It is used to perform a code coverage

**openzeppelin-test-helpers**
Website : https://docs.openzeppelin.com/test-helpers/
Assertion library for Ethereum smart contract testing


#### Truffle
**ganache-cli**
Website : https://www.npmjs.com/package/ganache-cli
Command line version of Ganache
Warning : This package has been deprecated
"openzeppelin-solidity": "^2.2.0",


**truffle-hdwallet-provider**
It permits to sign transaction for addresses when a Web3 provider is needed
Website : https://www.npmjs.com/package/@truffle/hdwallet-provider


#### Solidity
JavaScript bindings for the Solidity compiler.
Website : https://www.npmjs.com/package/solc
    "solc": "^0.7.5",
    "solidity-coverage": "^0.7.13",
    "solium": "^1.2.4",
    "truffle": "^5.1.57",
    "truffle-flattener": "^1.2.12",
    "truffle-hdwallet-provider": "0.0.6",
    "web3": "^1.0.0-beta.41"
	
	
#### Others

**dotenv**
Website : https://www.npmjs.com/package/dotenv
Loads environment variables from a .env file 

**eslint**
Website : https://eslint.org/
Static analyzer of the code


**ethereumjs-util**
Website : https://www.npmjs.com/package/ethereumjs-util
It contains a collection of utility functions for Ethereum (account, address, signature, ...)


**ethjs-abi**
Website : https://github.com/ethjs/ethjs-abi
Warning : indicated as experimental package on 22.08.2022
Encode and decode method and event from the smart contract abi

### Troubleshooting
When you installes the packages, the following errors may appear :
**WebSocket-Node**
* Error msg 
> 29419 error /usr/bin/git ls-remote -h -t git://github.com/frozeman/WebSocket-Node.git
> 29419 error
> 29419 error fatal: unable to connect to github.com:
* Solution
`git config --global url."https://".insteadOf git://`
See https://stackoverflow.com/questions/51630515/cannot-install-web3-node-module

#### Python
Date : 22.09.2022
**No executable**
* Error msg 
> "gyp ERR! stack Error: Can't find Python executable "python", you can set the PYTHON env variable"
> Install an executable python in your machine

* Solution
You need to config your executable python for npm
Example : 
`npm config set python "/usr/bin/python2.7"`
More information here : https://stackoverflow.com/questions/69106485/wls2-ubuntu-npm-err-gyp-err-stack-error-cant-find-python-executable-python

**Error whith python3**
Date : 22.09.2022
* Error msg 
> gyp ERR! configure error 
> gyp ERR! stack Error: Command failed: /usr/bin/python3.8 -c import sys; print "%s.%s.%s" % sys.version_info[:3]; 
* Solution
One of the project libraries is probably written in pyton2. Or the version of pyhton used is python3. Change the config to python2.7
``npm config set python "/usr/bin/python2.7"``
**C Compiler**
* Error msg 
> configure: error: no acceptable C compiler found in $PATH
* Solution
You need to install a C compiler on your OS
See : https://askubuntu.com/questions/237576/no-acceptable-c-compiler-found-in-path
