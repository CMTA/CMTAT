const { expect } = require('chai')
const {
  deployCMTATLightStandalone,
  fixture,
  loadFixture
} = require('../deploymentUtils')
const ERC20BaseModuleCommon = require('../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../common/EnforcementModuleCommon')
const ERC20EnforcementModuleCommon = require('../common/ERC20EnforcementModuleCommon')
const VALUE = 20n
describe('CMTAT Core - Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATLightStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.core = true
  })
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
})
