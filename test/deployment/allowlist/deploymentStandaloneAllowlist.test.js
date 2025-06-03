const { expect } = require('chai')
const {
  deployCMTATAllowlistStandalone,
  fixture,
  loadFixture

} = require('../../deploymentUtils')
const {
  ZERO_ADDRESS
} = require('../../utils')
// Core
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
// Extensions
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const AllowlistModuleCommon = require('../../common/AllowlistModuleCommon')
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
describe('CMTAT Allowlist- Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATAllowlistStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    const accounts = [this.address1, this.address2, this.address3, this.admin]
    const Allowlist = [true, true, true, true]
    await this.cmtat
      .connect(this.admin)
      .batchSetAddressAllowlist(accounts,  Allowlist)
    this.core = true
    this.dontCheckTimestamp = true
  })
  // core
  BaseModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()
  // Extensions
  ERC20EnforcementModuleCommon()
  DocumentModuleCommon()
  ExtraInfoModuleCommon()
  // Options
  AllowlistModuleCommon()
})
