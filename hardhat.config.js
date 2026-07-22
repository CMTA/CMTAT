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
  networks: {
    hardhat: {
      blockGasLimit: 30000000,
      // Test-only: relaxes the runtime EIP-170 (24 KB) deploy check so oversized
      // test *mocks* (e.g. CMTATUpgradeableERC1363MsgDataMock, which extends the
      // full ERC1363 token and adds a getMsgData() helper) can be deployed.
      // Production contracts are still guarded: contractSizer.strict below throws
      // at compile time for any non-Mock contract over the limit, and real
      // networks enforce EIP-170 regardless of this flag.
      allowUnlimitedContractSize: true
    }
  },
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
