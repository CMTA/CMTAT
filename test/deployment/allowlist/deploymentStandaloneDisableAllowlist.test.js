const { expect } = require('chai')
const {
  deployCMTATAllowlistStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const { ZERO_ADDRESS } = require('../../utils')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const VersionModuleCommon = require('../../common/VersionModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
describe('CMTAT Disable Allowlist- Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATAllowlistStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    await this.cmtat.connect(this.admin).enableAllowlist(false)
    this.erc1404 = true
    this.dontCheckTimestamp = true
  })
  // core
  VersionModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()
  // Extensions
  DocumentModuleCommon()
  ExtraInfoModuleCommon()
  ERC20EnforcementModuleCommon
})
