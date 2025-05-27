const { expect } = require('chai')
const {
  deployCMTATWhitelistProxy,
  fixture,
  loadFixture

} = require('../../deploymentUtils')
const {
  ZERO_ADDRESS
} = require('../../utils')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
describe('CMTAT Whitelist - Upgradeable', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATWhitelistProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.cmtat.setAddressWhitelisted(this.address1, true)
    this.cmtat.setAddressWhitelisted(this.address2, true)
    this.cmtat.setAddressWhitelisted(this.address3, true)
    this.cmtat.setAddressWhitelisted(this.admin, true)
    this.core = true
  })
  BaseModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()
})
