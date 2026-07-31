/** @type import('hardhat/config').HardhatUserConfig */
require('@openzeppelin/hardhat-upgrades')
require('solidity-coverage')
require("hardhat-contract-sizer");
require("@nomicfoundation/hardhat-chai-matchers")

// solidity-coverage instruments every contract, and the instrumented bytecode of
// the largest deployment variants costs more than the EIP-7825 per-transaction
// gas cap (2**24 = 16,777,216 gas) to deploy, which the `osaka` hardfork enforces
// ("Transaction ran out of gas"). Coverage runs therefore fall back to `prague`,
// the last hardfork before that cap; HARDHAT_HARDFORK overrides both.
const isCoverageRun = process.argv.includes("coverage");
const hardfork = process.env.HARDHAT_HARDFORK || (isCoverageRun ? "prague" : "osaka");

const deactivateReportGas = process.env.DeactivateReportGas === "true" || process.env.DeactivateReportGas === "1";
const reportGas = !deactivateReportGas;
if (reportGas) {
  require("hardhat-gas-reporter");
}
module.exports = {
  networks: {
    hardhat: {
      // `osaka` for the test run (same target as the compiler), `prague` under
      // coverage — see the isCoverageRun comment above.
      hardfork,
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
