require('dotenv').config()

const CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')

module.exports = async function (deployer, _network, account) {
  const admin = process.env.ADMIN_ADDRESS ? process.env.ADMIN_ADDRESS : account[0]
  const flag = 0
  const proxyContract = await deployProxy(
    CMTAT_PROXY,
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
  await CMTAT_PROXY.deployed()
  console.log('Proxy deployed at: ', proxyContract.address)
}
