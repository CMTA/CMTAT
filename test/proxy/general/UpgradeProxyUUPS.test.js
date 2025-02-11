const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const { ZERO_ADDRESS, PROXY_UPGRADE_ROLE } = require('../../utils')
const UpgradeProxyCommon = require('./UpgradeProxyCommon')

const {
  DEPLOYMENT_DECIMAL,
  fixture,
  loadFixture,
  TERMS
} = require('../../deploymentUtils')
describe('CMTAT with UUPS Proxy', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))

    // Deploy the implementation contract
    CMTAT_PROXY_FACTORY = await ethers.getContractFactory('CMTAT_PROXY_UUPS')
    this.CMTAT_PROXY_TestFactory = await ethers.getContractFactory(
      'CMTAT_PROXY_TEST_UUPS'
    )
    this.IsUUPSProxy = true
    this.CMTAT = await upgrades.deployProxy(
      CMTAT_PROXY_FACTORY,
      [
        this.admin.address,
        ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
        ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
        [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
      ],
      {
        initializer: 'initialize',
        kind: 'uups',
        constructorArgs: [this._.address]
      }
    )
  })

  UpgradeProxyCommon()

  it('testAdminCanUpgradeProxy', async function () {
    await upgrades.upgradeProxy(
      this.CMTAT.target,
      this.CMTAT_PROXY_TestFactory.connect(this.admin),
      {
        constructorArgs: [this._.address],
        kind: 'uups'
      }
    )
  })

  it('testNonAdminCanNotUpgradeProxy', async function () {
    await expect(
      upgrades.upgradeProxy(
        this.CMTAT.target,
        this.CMTAT_PROXY_TestFactory.connect(this.address1),
        {
          constructorArgs: [this._.address],
          kind: 'uups'
        }
      )
    )
      .to.be.revertedWithCustomError(
        this.CMTAT,
        'AccessControlUnauthorizedAccount'
      )
      .withArgs(this.address1.address, PROXY_UPGRADE_ROLE)
  })
})
