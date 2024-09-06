require('dotenv').config()
const { ethers, upgrades } = require('hardhat')
const {
  printBoxedTitle
} = require('./utils')
const tokensMetadata = require('./wrapped-tokens.json')

async function deployWrappedAsset (CMTATBase, metadata) {
  const proxyContract = await upgrades.deployProxy(
    CMTATBase,
    metadata,
    { initializer: 'initialize' }
  )

  if (!proxyContract || !(await proxyContract.getAddress())) {
    throw new Error('Deployment failed. Proxy contract address is undefined.')
  }

  console.log('Deployed contract address: ', await proxyContract.getAddress())
}

async function deployWrappedAssets () {
  printBoxedTitle('Deploying 21DOGE to a new network')

  const CMTATBase = await ethers.getContractFactory('CMTAT_BASE')

  // Deploy 21DOGE as nonce 0
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0xD2aEE1CE2b4459dE326971DE036E82f1318270AF'].metadata
  )
}

async function main () {
  try {
    await deployWrappedAssets()
  } catch (error) {
    console.error('Deployment failed:', error)
    process.exit(1)
  }
}

main().then(() => process.exit(0))
