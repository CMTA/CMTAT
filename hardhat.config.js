/** @type import('hardhat/config').HardhatUserConfig */
require('@openzeppelin/hardhat-upgrades')
require('solidity-coverage')
require("hardhat-gas-reporter");
require('solidity-docgen')
require("hardhat-contract-sizer");
require("@nomicfoundation/hardhat-chai-matchers")
module.exports = {
  solidity: {
    version: '0.8.28',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: 'cancun'
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
