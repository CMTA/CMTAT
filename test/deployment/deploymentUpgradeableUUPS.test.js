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
const VersionModuleCommon = require('../common/VersionModuleCommon')
const PauseModuleCommon = require('../common/PauseModuleCommon')
// Extensions
const ERC20EnforcementModuleCommon = require('../common/ERC20EnforcementModuleCommon')
const DocumentModuleCommon = require('../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../common/ExtraInfoModuleCommon')
// options
const ERC20CrossChainModuleCommon = require('../common/ERC20CrossChainModuleCommon')
const CCIPModuleCommon = require('../common/CCIPModuleCommon')

describe('CMTAT UUPS', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATUUPSProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc1404 = true
  })
  // Core
  VersionModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()

  // Extensions
  ERC20EnforcementModuleCommon()
  DocumentModuleCommon()
  ExtraInfoModuleCommon()

  // options
  ERC20CrossChainModuleCommon()
  CCIPModuleCommon()
})
