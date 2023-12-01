require('dotenv').config()
const { ethers, upgrades } = require('hardhat')

// Helper function to print titles in a box format
function printBoxedTitle (title) {
  const line = '='.repeat(title.length + 4)
  console.log(`\n+${line}+\n|  ${title}  |\n+${line}+\n`)
}

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

// Verify a contract on Etherscan
async function verifyOnExplorer (contractAddress, constructorArguments = []) {
  console.log('Verifying contract on explorer...')
  await run('verify:verify', { address: contractAddress, constructorArguments })
  console.log(`Verification submitted for contract at address: ${contractAddress}`)
}

// Verify different components of the contract
async function verifyProxyContract (proxyContract) {
  printBoxedTitle('Verifying Proxy Contract')
  const proxyAddress = await proxyContract.getAddress()
  console.log('Proxy contract address:', proxyAddress, '\n')
  await verifyOnExplorer(proxyAddress, getInitializerArguments(await getAdminAddress()))

  // Note: Verification of the proxy contract may be unnecessary but is included for completeness.
}

async function verifyProxyAdminContract (proxyContract) {
  printBoxedTitle('Verifying Proxy Admin Contract')
  const proxyAdminAddress = await upgrades.erc1967.getAdminAddress(await proxyContract.getAddress())
  console.log('Proxy Admin contract address:', proxyAdminAddress, '\n')
  await verifyOnExplorer(proxyAdminAddress)

  // Note: Verification of the proxy admin contract may be unnecessary but is included for completeness.
}

async function verifyImplementationContract (proxyContract) {
  printBoxedTitle('Verifying Implementation Contract')
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(await proxyContract.getAddress())
  console.log('Implementation contract address:', implementationAddress, '\n')
  await verifyOnExplorer(implementationAddress)
}

// Main verification function
async function verifyContract (proxyContract) {
  const delay = 30000 // 30-second delay for network propagation
  console.log(`\nWaiting ${delay / 1000} seconds for the network to propagate...`)
  await new Promise(resolve => setTimeout(resolve, delay))

  await verifyProxyContract(proxyContract)
  await verifyProxyAdminContract(proxyContract)
  await verifyImplementationContract(proxyContract)
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
