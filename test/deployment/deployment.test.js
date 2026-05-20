const { ZERO_ADDRESS} = require('../utils')
const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const {
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter,
  deployCMTATProxy,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../deploymentUtils')
describe('CMTAT - Deployment', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtatCustomError = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
    // Act + Assert
    await expect(
      deployCMTATProxyWithParameter(
        this.deployerAddress.address,
        this._.address,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DEPLOYMENT_DECIMAL,
        'CMTAT_ISIN',
        TERMS,
        'CMTAT_info',
        [ZERO_ADDRESS]
      )
    ).to.be.revertedWithCustomError(
      this.cmtatCustomError,
      'CMTAT_AccessControlModule_AddressZeroNotAllowed'
    )
  })
  it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
    // Act + Assert
    await expect(
      deployCMTATStandaloneWithParameter(
        this.deployerAddress.address,
        this._.address,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DEPLOYMENT_DECIMAL,
        'CMTAT_ISIN',
        TERMS,
        'CMTAT_info',
        [ZERO_ADDRESS]
      )
    ).to.be.revertedWithCustomError(
      this.cmtatCustomError,
      'CMTAT_AccessControlModule_AddressZeroNotAllowed'
    )
  })

  it('testCanInitializeStandardProxyManually', async function () {
    const CMTATFactory = await ethers.getContractFactory('CMTATStandardUpgradeable')
    const cmtat = await upgrades.deployProxy(CMTATFactory, [], {
      initializer: false,
      constructorArgs: [this._.address],
      from: this.deployerAddress.address,
      unsafeAllow: ['missing-initializer']
    })

    await cmtat.initialize(
      this.admin.address,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS]
    )

    expect(await cmtat.ruleEngine()).to.equal(ZERO_ADDRESS)
  })

  it('testCanInitializeStandardProxyWithRuleEngine', async function () {
    const ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
      this.admin.address
    ])
    const CMTATFactory = await ethers.getContractFactory('CMTATStandardUpgradeable')
    const cmtat = await upgrades.deployProxy(CMTATFactory, [], {
      initializer: false,
      constructorArgs: [this._.address],
      from: this.deployerAddress.address,
      unsafeAllow: ['missing-initializer']
    })

    await cmtat.initialize(
      this.admin.address,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ruleEngineMock.target]
    )

    expect(await cmtat.ruleEngine()).to.equal(ruleEngineMock.target)
  })

  it('testCannotInitializeStandardProxyTwice', async function () {
    const CMTATFactory = await ethers.getContractFactory('CMTATStandardUpgradeable')
    const cmtat = await upgrades.deployProxy(CMTATFactory, [], {
      initializer: false,
      constructorArgs: [this._.address],
      from: this.deployerAddress.address,
      unsafeAllow: ['missing-initializer']
    })

    await cmtat.initialize(
      this.admin.address,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS]
    )

    await expect(
      cmtat.initialize(
        this.admin.address,
        ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
        ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
        [ZERO_ADDRESS]
      )
    ).to.be.revertedWithCustomError(cmtat, 'InvalidInitialization')
  })
})
