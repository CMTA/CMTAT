require('dotenv').config()

module.exports = {
  networks: {
    ganache: {
      host: "127.0.0.1",
      port: 8555,
      network_id: "*", // match any network
    },
    live: {
      host: "178.25.19.88", // Random IP for example purposes (do not use)
      port: 80,
      network_id: 1,        // Ethereum public network
      // optional config values:
      // gas
      // gasPrice
      // from - default address to use for any transaction Truffle makes during migrations
      // provider - web3 provider instance Truffle should use to talk to the Ethereum network.
      //          - function that returns a web3 provider instance (see below.)
      //          - if specified, host and port are ignored.
      // skipDryRun: - true if you don't want to test run the migration locally before the actual migration (default is false)
      // timeoutBlocks: - if a transaction is not mined, keep waiting for this number of blocks (default is 50)
    }
  },
  compilers: {
    solc: {
      version: '0.8.17',
      settings: {
        optimizer: {
          enabled: true,
          runs: 500
        }
      }
    }
  },
  plugins: [
    'truffle-contract-size'
  ]
}
