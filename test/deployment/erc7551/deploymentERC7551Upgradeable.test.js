const { expect } = require('chai')
const {
  deployCMTATERC7551Proxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
// Core
const VersionModuleCommon = require('../../common/VersionModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
// Extensions
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const ERC20EnforcementERC7551ModuleCommon = require('../../common/ERC20EnforcementERC7551ModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
// options
const ERC20CrossChainModuleCommon = require('../../common/ERC20CrossChainModuleCommon')
const ERC7551ModuleCommon = require('../../common/ERC7551ModuleCommon')
const CCIPModuleCommon = require('../../common/CCIPModuleCommon')

const VALUE = 20n
describe('CMTAT - ERC-7551 Proxy Deployment', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATERC7551Proxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc7551 = true
    // this.dontCheckTimestamp = true
  })
  // Core
  VersionModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  PauseModuleCommon()

  // Extensions
  ERC20EnforcementModuleCommon()
  ERC20EnforcementERC7551ModuleCommon()
  DocumentModuleCommon()
  ExtraInfoModuleCommon()

  // options
  ERC20CrossChainModuleCommon()
  ERC7551ModuleCommon()
  CCIPModuleCommon()

})
