const { expect } = require('chai')
const {
  deployCMTATERC1363Standalone,
  fixture,
  loadFixture
} = require('../deploymentUtils')
const ERC20BaseModuleCommon = require('../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../common/EnforcementModuleCommon')
const ERC20EnforcementModuleCommon = require('../common/ERC20EnforcementModuleCommon')
const VALUE = 20n
describe('CMTAT ERC1363 - Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATERC1363Standalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )

    const ReceiverMockFactory = await ethers.getContractFactory(
      'ERC1363ReceiverMock'
    )
    this.receiverMock = await ReceiverMockFactory.deploy()
  })

  /* ============ ERC165 ============ */
  it('testSupportRightInterface', async function () {
    const erc1363Interface = '0xb0202a11'
    // don't really know how to compute this easily
    //  type(IAccessControl).interfaceId
    const IERC165Interface = '0x01ffc9a7'
    const IERC721Interface = '0x80ac58cd'
    // Assert
    expect(await this.cmtat.supportsInterface(erc1363Interface)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC165Interface)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC721Interface)).to.equal(
      false
    )
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
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ERC20EnforcementModuleCommon()
})
