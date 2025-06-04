const { expect } = require('chai')
const {
  deployCMTATUUPSProxy,
  fixture,
  loadFixture
} = require('../deploymentUtils')
// Core
const ERC20BaseModuleCommon = require('../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../common/EnforcementModuleCommon')
const BaseModuleCommon = require('../common/BaseModuleCommon')
const PauseModuleCommon = require('../common/PauseModuleCommon')
// options
const ERC20CrossChainModuleCommon = require('../common/ERC20CrossChainModuleCommon')
const VALUE = 20n
describe('CMTAT Core - Upgradeable', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATUUPSProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.core = true
  })
  // Core
  BaseModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  // options
  ERC20CrossChainModuleCommon()
})
