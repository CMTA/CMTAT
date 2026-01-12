const { ZERO_ADDRESS,
  IERC165_INTERFACEID, IERC721_INTERFACEID,IACCESSCONTROL_INTERFACEID,
  IERC5679_INTERFACEID } = require('../utils')
const { expect } = require('chai')
const {
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter,
  deployCMTATProxy,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../deploymentUtils')
describe('CMTAT - Deployment', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtatCustomError = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
    // Act + Assert
    await expect(
      deployCMTATProxyWithParameter(
        this.deployerAddress.address,
        this._.address,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DEPLOYMENT_DECIMAL,
        'CMTAT_ISIN',
        TERMS,
        'CMTAT_info',
        [ZERO_ADDRESS]
      )
    ).to.be.revertedWithCustomError(
      this.cmtatCustomError,
      'CMTAT_AccessControlModule_AddressZeroNotAllowed'
    )
  })
  it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
    // Act + Assert
    await expect(
      deployCMTATStandaloneWithParameter(
        this.deployerAddress.address,
        this._.address,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DEPLOYMENT_DECIMAL,
        'CMTAT_ISIN',
        TERMS,
        'CMTAT_info',
        [ZERO_ADDRESS]
      )
    ).to.be.revertedWithCustomError(
      this.cmtatCustomError,
      'CMTAT_AccessControlModule_AddressZeroNotAllowed'
    )
  })

  /* ============ ERC165 ============ */
  it('testSupportRightInterface', async function () {
    // Assert
    expect(await this.cmtat.supportsInterface(IACCESSCONTROL_INTERFACEID)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC165_INTERFACEID)).to.equal(true)
    expect(await this.cmtat.supportsInterface(IERC721_INTERFACEID)).to.equal(
         false)
    expect(await this.cmtat.supportsInterface(IERC5679_INTERFACEID)).to.equal(true)
  })
})
