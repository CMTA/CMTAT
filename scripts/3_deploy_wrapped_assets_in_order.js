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
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0x3f67093dfFD4F0aF4f2918703C92B60ACB7AD78b'].metadata
  )

  // Deploy 21XRP as nonce 10
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0x0d3bd40758dF4F79aaD316707FcB809CD4815Ffe'].metadata
  )

  // Deploy 21BNB as nonce 11
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0x1bE9d03BfC211D83CFf3ABDb94A75F9Db46e1334'].metadata
  )

  // Deploy 21ADA as nonce 12
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0x9c05d54645306d4C4EAd6f75846000E1554c0360'].metadata
  )

  // Deploy 21SOL as nonce 13
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0xb80a1d87654BEf7aD8eB6BBDa3d2309E31D4e598'].metadata
  )

  // Deploy 21LTC as nonce 14
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0x9F2825333aa7bC2C98c061924871B6C016e385F3'].metadata
  )

  // Deploy 21DOT as nonce 15
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0xF4ACCD20bFED4dFFe06d4C85A7f9924b1d5dA819'].metadata
  )

  // Deploy 21BCH as nonce 16
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0xFf4927e04c6a01868284F5C3fB9cba7F7ca4aeC0'].metadata
  )

  // Send 3 dummy transfers to get to nonce 19
  for (let i = 0; i < 3; i++) {
    await deployer.sendTransaction({
      to: deployer.address,
      value: 1 // Wei
    })
  }

  // Deploy 21AVAX as nonce 20
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0x399508A43d7E2b4451cd344633108b4d84b33B03'].metadata
  )

  // Send 5 dummy transfers to get to nonce 25
  for (let i = 0; i < 5; i++) {
    await deployer.sendTransaction({
      to: deployer.address,
      value: 1 // Wei
    })
  }

  // Deploy 21TON as nonce 26
  await deployWrappedAsset(
    CMTATBase,
    tokensMetadata.tokens['0x73225F88fEEA4E41Fc67E986a95AC61dd7118866'].metadata
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
