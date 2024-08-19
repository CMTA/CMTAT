require('dotenv').config()
const { ethers, upgrades } = require('hardhat')
const {
  printBoxedTitle
} = require('./utils')
const tokensMetadata = require('./wrapped-tokens.json');

async function deployWrappedAssets () {
  printBoxedTitle('Deploying WRAPPED ASSETS to new network')

  const [deployer] = await ethers.getSigners()

  // First dummy transfer as nonce 0
  await deployer.sendTransaction({
    to: deployer.address,
    value: 1 // Wei
  })

  // Deploy ProxyAdmin as nonce 1
  const proxyAdminContract = await upgrades.deployProxyAdmin()
  console.log('proxyAdmin', proxyAdminContract)

  // Send 6 dummy transfers to get to nonce 7
  for (let i = 0; i < 6; i++) {
    await deployer.sendTransaction({
      to: deployer.address,
      value: 1 // Wei
    })
  }

  // Deploy Implementation as nonce 8
  const CMTATBase = await ethers.getContractFactory('CMTAT_BASE')
  const deployedImplementation = await upgrades.deployImplementation(CMTATBase)
  console.log('Implementation', deployedImplementation)

  // Deploy 21BTC as nonce 9
  const proxyContract = await upgrades.deployProxy(
    CMTATBase,
    tokensMetadata.tokens[0]['0x3f67093dfFD4F0aF4f2918703C92B60ACB7AD78b'].metadata,
    { initializer: 'initialize' }
  )

  if (!proxyContract || !(await proxyContract.getAddress())) {
    throw new Error('Deployment failed. Proxy contract address is undefined.')
  }

  console.log('Deployed contract object:\n', proxyContract)
  console.log('@ : ', await proxyContract.getAddress())
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
