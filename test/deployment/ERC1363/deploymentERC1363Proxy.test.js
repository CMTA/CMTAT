const { expect } = require('chai')
const {
  deployCMTATERC1363Proxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const {
  IERC165_INTERFACEID, IERC721_INTERFACEID,IACCESSCONTROL_INTERFACEID,
  IERC1363_INTERFACEID, IERC5679_INTERFACEID
} = require('../../utils')

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
const CCIPModuleCommon = require('../../common/CCIPModuleCommon')
const VALUE = 20n
describe('CMTAT - ERC1363 Proxy Deployment', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATERC1363Proxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc7551 = true
    this.dontCheckTimestamp = true
    const ReceiverMockFactory = await ethers.getContractFactory(
      'ERC1363ReceiverMock'
    )
    this.receiverMock = await ReceiverMockFactory.deploy()
  })
  /* ============ ERC165 ============ */
  it('testSupportRightInterface', async function () {
    // Assert
    expect(await this.cmtat.supportsInterface(IACCESSCONTROL_INTERFACEID)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC165_INTERFACEID)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC721_INTERFACEID)).to.equal(
         false)
    expect(await this.cmtat.supportsInterface(IERC5679_INTERFACEID)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC1363_INTERFACEID)).to.equal(true)
  })
  it('testCanSendTokenToReceiverContract', async function () {
    // Arrange
    await this.cmtat.connect(this.admin).mint(this.admin, VALUE)
    // Arrange - Assert
    // Check balance before transfer
    expect(await this.cmtat.balanceOf(this.receiverMock)).to.equal(0)

    // Act + Assert
    await expect(
      this.cmtat.connect(this.admin).transferAndCall(this.receiverMock, VALUE)
    )
      .to.emit(this.cmtat, 'Transfer')
      .withArgs(this.admin, this.receiverMock, VALUE)

    // Assert
    expect(await this.cmtat.balanceOf(this.receiverMock)).to.equal(VALUE)
  })
  it('testCannotSendTokenToEOAWithERC1363Functions', async function () {
    // Arrange
    await this.cmtat.connect(this.admin).mint(this.admin, VALUE)
    await expect(
      this.cmtat.connect(this.admin).transferAndCall(this.address1, VALUE)
    )
      .to.be.revertedWithCustomError(this.cmtat, 'ERC1363InvalidReceiver')
      .withArgs(this.address1.address)
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
  CCIPModuleCommon()

})
