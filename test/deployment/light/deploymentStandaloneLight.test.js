const { expect } = require('chai')
const {
  deployCMTATLightStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const { ZERO_ADDRESS, DEFAULT_ADMIN_ROLE } = require('../../utils')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const VersionModuleCommon = require('../../common/VersionModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
const REASON_STRING = 'BURN_TEST'
const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON = ethers.Typed.bytes(REASON_EVENT)
const INITIAL_SUPPLY = 50n
const VALUE1 = 20n
const DIFFERENCE = INITIAL_SUPPLY - VALUE1
describe('CMTAT Core - Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATLightStandalone(
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc1404 = true
  })
  VersionModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()
  async function testBurn (sender) {
    // Act
    // Burn 20
    this.logs = await this.cmtat
      .connect(sender)
      .forcedBurn(this.address1, VALUE1, REASON)
    // Assert
    // emits a Transfer event
    await expect(this.logs)
      .to.emit(this.cmtat, 'Transfer')
      .withArgs(this.address1, ZERO_ADDRESS, VALUE1)
    // Emits a Burn event
    await expect(this.logs)
      .to.emit(this.cmtat, 'Enforcement')
      .withArgs(sender, this.address1, VALUE1, REASON_EVENT)
    // Check balances and total supply
    expect(await this.cmtat.balanceOf(this.address1)).to.equal(DIFFERENCE)
    expect(await this.cmtat.totalSupply()).to.equal(DIFFERENCE)

    // Burn 30
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .forcedBurn(this.address1, DIFFERENCE, REASON)

    // Assert
    // Emits a Transfer event
    await expect(this.logs)
      .to.emit(this.cmtat, 'Transfer')
      .withArgs(this.address1, ZERO_ADDRESS, DIFFERENCE)
    // Emits a Burn event
    await expect(this.logs)
      .to.emit(this.cmtat, 'Enforcement')
      .withArgs(this.admin, this.address1, DIFFERENCE, REASON_EVENT)
    // Check balances and total supply
    expect(await this.cmtat.balanceOf(this.address1)).to.equal(0)
    expect(await this.cmtat.totalSupply()).to.equal(0)
  }

  it('testCanBeBurntByAdminIfFrozen', async function () {
    await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY)
    expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
    await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true)
    const bindTest = testBurn.bind(this)
    await bindTest(this.admin)
  })

  it('testCannotBeForcedBurnByNonAdmin', async function () {
    // Act
    await expect(
      this.cmtat
        .connect(this.address2)
        .forcedBurn(this.address1, VALUE1, REASON)
    )
      .to.be.revertedWithCustomError(
        this.cmtat,
        'AccessControlUnauthorizedAccount'
      )
      .withArgs(this.address2.address, DEFAULT_ADMIN_ROLE)
  })

  it('testCannotBeBurntByAdminIfNotFrozen', async function () {
    await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY)
    expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
    await expect(
      this.cmtat
        .connect(this.admin)
        .forcedBurn(this.address1, DIFFERENCE, REASON)
    ).to.be.revertedWithCustomError(
      this.cmtat,
      'CMTAT_BurnEnforcement_AddressIsNotFrozen'
    )
  })

  /* ============ ERC165 ============ */
  it('testSupportRightInterface', async function () {
    const erc1363Interface = '0xb0202a11'
    // don't really know how to compute this easily
    //  type(IAccessControl).interfaceId
    const IERC165Interface = '0x01ffc9a7'
    const IERC721Interface = '0x80ac58cd'
    const IERC5679 = '0xd0017968'
    // Assert
    expect(await this.cmtat.supportsInterface(erc1363Interface)).to.equal(
      false
    )
    expect(await this.cmtat.supportsInterface(IERC165Interface)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC721Interface)).to.equal(
      false
    )
    expect(await this.cmtat.supportsInterface(IERC5679)).to.equal(true)
  })
})
