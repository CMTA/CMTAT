require('dotenv').config()

let networks = {}
if (process.env.SOLIDITY_COVERAGE) {
  networks = {
    coverage: {
      host: 'localhost',
      network_id: '*', // eslint-disable-line camelcase
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    }
  }
} else {
  const HDWalletProvider = require('truffle-hdwallet-provider')
  const conf = process.env
  const providerWithMnemonic = (mnemonic, rpcEndpoint) => {
    if (mnemonic && rpcEndpoint) {
      return new HDWalletProvider(mnemonic, rpcEndpoint, 0, 10)
    }
    return undefined
  }

  let loadNetworks = false
  for (let i = 3; i < process.argv.length && !loadNetworks; i++) {
    loadNetworks = process.argv[i].startsWith('--network')
  }

  if (loadNetworks) {
    networks = {
      development: {
        host: '127.0.0.1',
        port: 8545,
        network_id: '*' // Match any network id
      }
    }
  }
}

module.exports = {
  networks,
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
    'truffle-contract-size'
  ]
}
