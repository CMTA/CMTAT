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
    version: '0.8.36',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: 'osaka'
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
  mocha: {
    // The upgradeable (proxy) suites redeploy a full CMTAT implementation through
    // `upgrades.deployProxy` (implementation validation + storage-layout analysis
    // + deploy) in a per-test `beforeEach`. That is legitimately slow and can spike
    // past Mocha's 40s default on a loaded CI runner, producing flaky "before each"
    // timeouts (e.g. the UUPS suite). Raise the ceiling so CI variance on a valid,
    // non-hung deploy does not fail the run; genuine hangs are still caught.
    timeout: 120000
  },
}
