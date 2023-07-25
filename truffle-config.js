require('dotenv').config()
const HDWalletProvider = require('@truffle/hdwallet-provider')

module.exports = {
  networks: {
    ganache: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*' // match any network
    },
    live: {
      host: '178.25.19.88',
      port: 80,
      network_id: 1 // Ethereum public network
      // optional config values:
      // gas
      // gasPrice
      // from - default address to use for any transaction Truffle makes during migrations
      // provider - web3 provider instance Truffle should use to talk to the Ethereum network.
      //          - function that returns a web3 provider instance (see below.)
      //          - if specified, host and port are ignored.
      // skipDryRun: - true if you don't want to test run the migration locally before the actual migration (default is false)
      // timeoutBlocks: - if a transaction is not mined, keep waiting for this number of blocks (default is 50)
    },
    goerli: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.GOERLI_NODE)
      },
      network_id: '5', // eslint-disable-line camelcase
    },
    polygon: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.POLYGON_NODE)
      },
      network_id: '137', // eslint-disable-line camelcase,
      gasPrice: "450000000000"
    },
    mainnet: {
      provider: () => {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.MAINNET_NODE)
      },
      network_id: '1', // eslint-disable-line camelcase
    },
  },
  compilers: {
    solc: {
      version: '0.8.17',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  },
  plugins: [
    'truffle-contract-size',
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY,
    polygonscan: process.env.POLYGONSCAN_API_KEY,
  },
}
