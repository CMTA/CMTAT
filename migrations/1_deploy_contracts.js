require('dotenv').config()

const CMTAT_BASE = artifacts.require('CMTAT_BASE')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')

module.exports = async function (deployer, _network, account) {
  const admin = process.env.ADMIN_ADDRESS ? process.env.ADMIN_ADDRESS : account[0]
  const flag = 0
  const proxyContract = await deployProxy(
    CMTAT_BASE,
    [
      admin,
      'Test CMTA Token',
      'TCMTAT',
      'TCMTAT_ISIN',
      'https://cmta.ch',
      'TCMTAT_info',
      flag
    ]
  )
  await CMTAT_BASE.deployed()
  console.log('Proxy deployed at: ', proxyContract.address)
}
