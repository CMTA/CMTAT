const { ethers, upgrades } = require('hardhat')

// Fetch the admin address
async function getAdminAddress () {
  const [deployer] = await ethers.getSigners()
  return process.env.ADMIN_ADDRESS || deployer.address
}

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

// Function to get the deployed proxy contract
async function getProxyContract (address) {
  const CMTATBase = await ethers.getContractFactory('CMTAT_BASE')
  const proxyContract = CMTATBase.attach(address)
  return proxyContract
}

// Helper function to print titles in a box format
function printBoxedTitle (title) {
  const line = '='.repeat(title.length + 4)
  console.log(`\n+${line}+\n|  ${title}  |\n+${line}+\n`)
}

async function verifyContract (proxyContract) {
  let delay = 30000 // 30-second delay for network propagation
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

  delay = 3000 // 3-second delay for network propagation
  console.log(`\nWaiting ${delay / 1000} seconds for the network to avoid rate-limit...`)
  await new Promise(resolve => setTimeout(resolve, delay))

  // Verify Proxy Admin Contract
  await performVerification(() => verifyProxyAdminContract(proxyContract), 'Proxy Admin')

  delay = 3000 // 3-second delay for network propagation
  console.log(`\nWaiting ${delay / 1000} seconds for the network to avoid rate-limit...`)
  await new Promise(resolve => setTimeout(resolve, delay))

  // Verify Implementation Contract
  await performVerification(() => verifyImplementationContract(proxyContract), 'Implementation')
}

// Verify a contract on Etherscan
async function verifyOnExplorer (contractAddress, constructorArguments = []) {
  console.log('Verifying contract on explorer...')
  await run('verify:verify', { address: contractAddress, constructorArguments })
  console.log(`Verification submitted for contract at address: ${contractAddress}`)
}

async function verifyImplementationContract (proxyContract) {
  printBoxedTitle('Verifying Implementation Contract')
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(await proxyContract.getAddress())
  console.log('Implementation contract address:', implementationAddress, '\n')
  await verifyOnExplorer(implementationAddress)
}

// Verify different components of the contract
async function verifyProxyContract (proxyContract, constructorArguments) {
  printBoxedTitle('Verifying Proxy Contract')
  const proxyAddress = await proxyContract.getAddress()
  console.log('Proxy contract address:', proxyAddress, '\n')
  await verifyOnExplorer(proxyAddress, constructorArguments)

  // Note: Verification of the proxy contract may be unnecessary but is included for completeness.
}

async function verifyProxyAdminContract (proxyContract) {
  printBoxedTitle('Verifying Proxy Admin Contract')
  const proxyAdminAddress = await upgrades.erc1967.getAdminAddress(await proxyContract.getAddress())
  console.log('Proxy Admin contract address:', proxyAdminAddress, '\n')
  await verifyOnExplorer(proxyAdminAddress)

  // Note: Verification of the proxy admin contract may be unnecessary but is included for completeness.
}

module.exports = {
  getAdminAddress,
  getInitializerArguments,
  getProxyContract,
  printBoxedTitle,
  verifyContract,
  verifyImplementationContract,
  verifyProxyAdminContract,
  verifyProxyContract,
  verifyOnExplorer
}
