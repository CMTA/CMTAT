const {
  deployCMTATERC7551Standalone,
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
const ERC7551ModuleCommon = require('../../common/ERC7551ModuleCommon')
const CCIPModuleCommon = require('../../common/CCIPModuleCommon')
// Extensions
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const ERC20EnforcementERC7551ModuleCommon = require('../../common/ERC20EnforcementERC7551ModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')

describe('CMTAT ERC7551 - Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATERC7551Standalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc7551 = true
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
  ERC7551ModuleCommon()
  CCIPModuleCommon()
  // Extensions
  ERC20EnforcementModuleCommon()
  ERC20EnforcementERC7551ModuleCommon()
  DocumentModuleCommon()
  ExtraInfoModuleCommon()
})
