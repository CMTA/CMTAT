/** @type import('hardhat/config').HardhatUserConfig */
require('@nomiclabs/hardhat-truffle5')
require('@openzeppelin/hardhat-upgrades')
require("hardhat-gas-reporter");
require("solidity-coverage")
require('solidity-docgen')
require("hardhat-contract-sizer");
module.exports = {
  solidity: {
    version: '0.8.22',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: 'shanghai'
    }
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    //only: [':ERC20$'],
  }
}
