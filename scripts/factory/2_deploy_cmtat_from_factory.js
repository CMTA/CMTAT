require('dotenv').config()
const { ethers } = require('hardhat')
const {
  getAdminAddress,
  printBoxedTitle,
  getInitializerArguments
} = require('../utils')

async function deployCMTATProxyFromFactory () {
  printBoxedTitle('Deploying CMTAT proxy from factory')

  const admin = await getAdminAddress()
  const CMTATFactory = await ethers.getContractFactory('CMTAT_FACTORY')
  const factoryContract = CMTATFactory.attach('0x53633587537FFA97084BE82F2Ef8671440Cf17F0')

  const salt = '0x3'
  const proxyAdminAddress = '0xdb1d9B95D72e5cb4B007C7f23BcAec215e9a6Fc9'

  // const proxyAddress = await factoryContract.computeProxyAddress(
  //   ethers.encodeBytes32String(salt),
  //   proxyAdminAddress
  //   getInitializerArguments(admin)
  // )

  const proxyAddress = await factoryContract.deployCMTAT(
    ethers.encodeBytes32String(salt),
    proxyAdminAddress,
    getInitializerArguments(admin)
  )

  if (!proxyAddress) {
    throw new Error('Deployment failed. Proxy contract address is undefined.')
  }

  return proxyAddress
}

// Main function
async function main () {
  try {
    const proxyAddress = await deployCMTATProxyFromFactory()
    console.log('Proxy deployed at:', proxyAddress)
  } catch (error) {
    console.error('Deployment failed:', error)
    process.exit(1)
  }
}

main().then(() => process.exit(0))
