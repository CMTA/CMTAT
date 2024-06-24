require('dotenv').config()
const { ethers, upgrades } = require('hardhat')
const {
  getAdminAddress,
  getInitializerArguments,
  printBoxedTitle,
  verifyContract
} = require('./utils')

// Deploy CMTAT_BASE Contract
async function deployCMTATBase () {
  printBoxedTitle('Deploying CMTAT_BASE Contract')

  const admin = await getAdminAddress()
  const CMTATBase = await ethers.getContractFactory('CMTAT_BASE')
  const proxyContract = await upgrades.deployProxy(CMTATBase, getInitializerArguments(admin), { initializer: 'initialize' })

  if (!proxyContract || !(await proxyContract.getAddress())) {
    throw new Error('Deployment failed. Proxy contract address is undefined.')
  }

  console.log('Deployed contract object:\n', proxyContract)
  return proxyContract
}

// Main function
async function main () {
  try {
    const proxyContract = await deployCMTATBase()
    console.log('Proxy deployed at:', await proxyContract.getAddress())
    await verifyContract(proxyContract)

    // Print summary of deployed contracts
    printBoxedTitle('Deployment Summary')
    const proxyAddress = await proxyContract.getAddress()
    const proxyAdminAddress = await upgrades.erc1967.getAdminAddress(proxyAddress)
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress)

    console.log(`Deployed Proxy Contract Address: ${proxyAddress}`)
    console.log(`Proxy Admin Contract Address: ${proxyAdminAddress}`)
    console.log(`Implementation Contract Address: ${implementationAddress}`)
  } catch (error) {
    console.error('Deployment failed:', error)
    process.exit(1)
  }
}

main().then(() => process.exit(0))
