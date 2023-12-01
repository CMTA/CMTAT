const { ethers, upgrades } = require('hardhat')

// Fetch the admin address
async function getAdminAddress () {
  const [deployer] = await ethers.getSigners()
  return process.env.ADMIN_ADDRESS || deployer.address
}

// Helper function to print titles in a box format
function printBoxedTitle (title) {
  const line = '='.repeat(title.length + 4)
  console.log(`\n+${line}+\n|  ${title}  |\n+${line}+\n`)
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
  printBoxedTitle,
  verifyImplementationContract,
  verifyProxyAdminContract,
  verifyProxyContract
}
