const {
  deployCMTATPermitStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
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

describe('CMTAT Permit - Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATPermitStandalone(
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
})
