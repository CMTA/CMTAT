require('dotenv').config()
const { ethers, upgrades } = require('hardhat')
const {
  getAdminAddress,
  printBoxedTitle
} = require('../utils')

// Deploy CMTAT_BASE Contract
async function deployCMTATFactory () {
  printBoxedTitle('Deploying CMTAT_FACTORY Contract')

  const admin = await getAdminAddress()
  const CMTATFactory = await ethers.getContractFactory('CMTAT_FACTORY')
  // const CMTATBase = await ethers.getContractFactory('CMTAT_BASE')
  // const deployedImplementation = await CMTATBase.deploy()
  // console.log('Implementation', await deployedImplementation.getAddress())
  // const proxyAdminContract = await upgrades.deployProxyAdmin()
  // console.log('proxyAdmin', proxyAdminContract)
  const deployedFactory = await CMTATFactory.deploy(
    '0x45E36B26a2717c131c6F9b2B3720A9241Da1714E',
    admin
  )

  if (!deployedFactory || !(await deployedFactory.getAddress())) {
    throw new Error('Deployment failed. Factory contract address is undefined.')
  }

  console.log('Deployed Factory contract object:\n', deployedFactory)
  return deployedFactory
}

// Main function
async function main () {
  try {
    const factoryContract = await deployCMTATFactory()
    console.log('Factory deployed at:', await factoryContract.getAddress())
  } catch (error) {
    console.error('Deployment failed:', error)
    process.exit(1)
  }
}

main().then(() => process.exit(0))
