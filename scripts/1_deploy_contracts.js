require('dotenv').config()
const { ethers, upgrades } = require('hardhat')
const {
  getAdminAddress,
  printBoxedTitle,
  verifyImplementationContract,
  verifyProxyAdminContract,
  verifyProxyContract
} = require('./utils')

// Initialize contract arguments
function getInitializerArguments (admin) {
  return [
    admin, // Admin address
    'Test CMTA Token', // nameIrrevocable
    'TCMTAT', // symbolIrrevocable
    18, // decimalsIrrevocable
    'TCMTAT_ISIN', // tokenId
    'https://cmta.ch', // terms
    'TCMTAT_info', // information
    0 // flag
  ]
}

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

// Main verification function
async function verifyContract (proxyContract) {
  const delay = 30000 // 30-second delay for network propagation
  console.log(`\nWaiting ${delay / 1000} seconds for the network to propagate...`)
  await new Promise(resolve => setTimeout(resolve, delay))

  const constructorArguments = getInitializerArguments(await getAdminAddress())

  // Helper function for individual verifications
  async function performVerification (verificationFunction, contractType) {
    try {
      await verificationFunction()
      console.log(`${contractType} contract verified successfully.`)
    } catch (error) {
      console.error(`Error verifying ${contractType} contract:`, error)
    }
  }

  // Verify Proxy Contract
  await performVerification(() => verifyProxyContract(proxyContract, constructorArguments), 'Proxy')

  // Verify Proxy Admin Contract
  await performVerification(() => verifyProxyAdminContract(proxyContract), 'Proxy Admin')

  // Verify Implementation Contract
  await performVerification(() => verifyImplementationContract(proxyContract), 'Implementation')
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
