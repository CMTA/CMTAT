require('dotenv').config()
const { ethers, upgrades } = require('hardhat')

async function deployCMTATBase () {
  const admin = await getAdminAddress()
  const CMTATBase = await ethers.getContractFactory('CMTAT_BASE')
  const proxyContract = await upgrades.deployProxy(
    CMTATBase,
    getInitializerArguments(admin),
    { initializer: 'initialize' }
  )
  await proxyContract.deployed()
  return proxyContract
}

async function getAdminAddress () {
  const [deployer] = await ethers.getSigners()
  return process.env.ADMIN_ADDRESS || deployer.address
}

function getInitializerArguments (admin) {
  return [
    admin,
    'Test CMTA Token', // nameIrrevocable
    'TCMTAT', // symbolIrrevocable
    18, // decimalsIrrevocable
    'TCMTAT_ISIN', // tokenId
    'https://cmta.ch', // terms
    'TCMTAT_info', // information
    0 // flag
  ]
}

async function verifyContract (proxyContract) {
  console.log('Verifying contract on Etherscan...')
  await run('verify:verify', {
    address: proxyContract.address,
    constructorArguments: getInitializerArguments(getAdminAddress())
  })
  console.log('Verification submitted to Etherscan.')
}

async function main () {
  try {
    const proxyContract = await deployCMTATBase()
    console.log('Proxy deployed at:', proxyContract.address)
    await verifyContract(proxyContract)
  } catch (error) {
    console.error('Deployment failed:', error)
    process.exit(1)
  }
}

main().then(() => process.exit(0))
