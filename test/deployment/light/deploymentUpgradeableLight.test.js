const { expect } = require('chai')
const {
  deployCMTATLightProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const VersionModuleCommon = require('../../common/VersionModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
describe('CMTAT Core - Upgradeable', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATLightProxy(
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc1404 = true
    this.core = true
  })
  // Core
  VersionModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()

  it('testSupportRightInterface', async function () {
    const erc1363Interface = '0xb0202a11'
    const IERC165Interface = '0x01ffc9a7'
    const IERC721Interface = '0x80ac58cd'
    const IERC5679 = '0xd0017968'
    const IERC8343 = '0xe9cd80b0'
    const IERC1404 = '0xab84a5c8'
    const IERC1404Extend = '0x78a8de7d'

    expect(await this.cmtat.supportsInterface(erc1363Interface)).to.equal(false)
    expect(await this.cmtat.supportsInterface(IERC165Interface)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC721Interface)).to.equal(false)
    expect(await this.cmtat.supportsInterface(IERC5679)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC8343)).to.equal(true)
    // The light deployment (CMTATBaseCore) does not include the ERC-1404 module
    expect(await this.cmtat.supportsInterface(IERC1404)).to.equal(false)
    expect(await this.cmtat.supportsInterface(IERC1404Extend)).to.equal(false)
    expect(await this.cmtat.supportsInterface('0xffffffff')).to.equal(false)
  })
})
