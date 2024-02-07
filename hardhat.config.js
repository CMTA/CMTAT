require('dotenv').config()
require('hardhat-contract-sizer')
require('hardhat-gas-reporter')
require('solidity-coverage')
require('solidity-docgen')
require('@openzeppelin/hardhat-upgrades')
require('@nomicfoundation/hardhat-verify')
require('@nomicfoundation/hardhat-chai-matchers')

module.exports = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
      chainId: 1
    },
    ganache: {
      url: 'http://127.0.0.1:8545',
      chainId: 1337
    },
    live: {
      url: 'http://178.25.19.88:80',
      chainId: 1
    },
    polygon: {
      url: process.env.POLYGON_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 137,
      gasPrice: 450000000000
    },
    holesky: {
      url: process.env.HOLESKY_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 17000
    },
    mainnet: {
      url: process.env.MAINNET_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1
    }
  },
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      holesky: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY
    }
  },
  gasReporter: {
    // eslint-disable-next-line no-unneeded-ternary
    enabled: (process.env.REPORT_GAS) ? true : false,
    currency: 'USD',
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    outputFile: 'gas-report.txt',
    noColors: true,
    token: 'ETH'
  }
}
