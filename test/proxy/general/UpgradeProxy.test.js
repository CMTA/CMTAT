const { expect } = require('chai')
const { ZERO_ADDRESS } = require('../../utils')
const UpgradeProxyCommon = require('./UpgradeProxyCommon')
const {
  DEPLOYMENT_DECIMAL,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const { ethers, upgrades } = require('hardhat')
let CMTAT_PROXY_FACTORY, CMTAT_PROXY_TEST_FACTORY, CMTAT_PROXY
describe('UpgradeableCMTAT - Proxy', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    /* Factory & Artefact */
    CMTAT_PROXY_FACTORY = await ethers.getContractFactory('CMTAT_PROXY')
    this.CMTAT_PROXY_TestFactory = await ethers.getContractFactory(
      'CMTAT_PROXY_TEST'
    )
    // Deployment
    this.CMTAT = await upgrades.deployProxy(
      CMTAT_PROXY_FACTORY,
      [
        this.admin.address,
        ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
        ['CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info'],
        [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
      ],
      {
        initializer: 'initialize',
        constructorArgs: [this._.address],
        from: this.deployerAddress.address
      }
    )
  })
  UpgradeProxyCommon()
})
