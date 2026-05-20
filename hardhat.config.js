/** @type import('hardhat/config').HardhatUserConfig */
require('@openzeppelin/hardhat-upgrades')
require('solidity-coverage')
require("hardhat-contract-sizer");
require("@nomicfoundation/hardhat-chai-matchers")

const deactivateReportGas = process.env.DeactivateReportGas === "true" || process.env.DeactivateReportGas === "1";
const reportGas = !deactivateReportGas;
if (reportGas) {
  require("hardhat-gas-reporter");
}
module.exports = {
  solidity: {
    version: '0.8.34',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: 'prague'
    }
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    except: [':.*Mock$'],
    //only: [':ERC20$'],
  },
  gasReporter: {
    enabled: reportGas
  },
}
