const {
  deployCMTATPermitProxy,
  DEPLOYMENT_DECIMAL,
  TERMS,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const { ZERO_ADDRESS } = require('../../utils')
// Core
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const VersionModuleCommon = require('../../common/VersionModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
// options
const ERC20CrossChainModuleCommon = require('../../common/ERC20CrossChainModuleCommon')
const CCIPModuleCommon = require('../../common/CCIPModuleCommon')
// Extensions
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
// Permit + Multicall
const PermitModuleCommon = require('../../common/PermitModuleCommon')
const MulticallModuleCommon = require('../../common/MulticallModuleCommon')

describe('CMTAT Permit - Upgradeable', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATPermitProxy(
      this.admin.address,
      this.deployerAddress.address
    )
  })
  // Core
  VersionModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()

  // options
  ERC20CrossChainModuleCommon()
  CCIPModuleCommon()

  // Extensions
  ERC20EnforcementModuleCommon()
  DocumentModuleCommon()
  ExtraInfoModuleCommon()

  // Permit + Multicall
  PermitModuleCommon()
  MulticallModuleCommon()

  context('Initializer', function () {
    it('testCanInitializePermitProxyManually', async function () {
      const factory = await ethers.getContractFactory('CMTATUpgradeablePermit')
      const cmtat = await upgrades.deployProxy(factory, [], {
        initializer: false,
        constructorArgs: [],
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

    it('testCannotInitializePermitProxyTwice', async function () {
      const factory = await ethers.getContractFactory('CMTATUpgradeablePermit')
      const cmtat = await upgrades.deployProxy(factory, [], {
        initializer: false,
        constructorArgs: [],
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
})
