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
    },
    sepolia: {
      url: process.env.SEPOLIA_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 11155111
    },
    arbitrum: {
      url: process.env.ARBITRUM_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 42161
    },
    arbitrumTestnet: {
      url: process.env.ARBITRUMTESTNET_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 421614
    },
    base: {
      url: process.env.BASE_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 8453
    },
    baseTestnet: {
      url: process.env.BASETESTNET_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 84532
    },
    bsc: {
      url: process.env.BSC_NODE,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 56
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
      polygon: process.env.POLYGONSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
      arbitrumOne: process.env.ARBISCAN_API_KEY,
      arbitrumTestnet: process.env.ARBISCAN_API_KEY,
      base: process.env.BASESCAN_API_KEY,
      baseTestnet: process.env.BASESCAN_API_KEY,
      bsc: process.env.BSCSCAN_API_KEY
    },
    customChains: [
      {
        network: 'holesky',
        chainId: 17000,
        urls: {
          apiURL: 'https://api-holesky.etherscan.io/api',
          browserURL: 'https://holesky.etherscan.io'
        }
      },
      {
        network: 'arbitrumTestnet',
        chainId: 421614,
        urls: {
          apiURL: 'https://api-sepolia.arbiscan.io/api',
          browserURL: 'https://sepolia.arbiscan.io/'
        }
      },
      {
        network: 'baseTestnet',
        chainId: 84532,
        urls: {
          apiURL: 'https://api-sepolia.basescan.org/api',
          browserURL: 'https://sepolia.basescan.org/'
        }
      }
    ]
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

