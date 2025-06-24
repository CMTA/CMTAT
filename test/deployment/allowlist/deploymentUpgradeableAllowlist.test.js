const { expect } = require('chai')
const {
  deployCMTATAllowlistProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const { ZERO_ADDRESS } = require('../../utils')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const AllowlistModuleCommon = require('../../common/AllowlistModuleCommon')
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
describe('CMTAT Allowlist - Upgradeable', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATAllowlistProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    const accounts = [this.address1, this.address2, this.address3, this.admin]
    const Allowlist = [true, true, true, true]
    await this.cmtat
      .connect(this.admin)
      .batchSetAddressAllowlist(accounts, Allowlist)
    this.erc1404 = true
    this.dontCheckTimestamp = true
  })
  // Core
  BaseModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()
  // Extensions
  DocumentModuleCommon()
  ExtraInfoModuleCommon()
  // options
  AllowlistModuleCommon()
})
