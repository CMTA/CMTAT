const { ZERO_ADDRESS } = require('../utils')
const { expect } = require('chai')
const {
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter,
  deployCMTATProxy,
  fixture,
  loadFixture
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
    const DECIMAL = 0
    // Act + Assert
    await expect(
      deployCMTATProxyWithParameter(
        this.deployerAddress.address,
        this._.address,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        'CMTAT_info',
        [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
      )
    ).to.be.revertedWithCustomError(
      this.cmtatCustomError,
      'CMTAT_AuthorizationModule_AddressZeroNotAllowed'
    )
  })
  it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
    const DECIMAL = 0
    // Act + Assert
    await expect(
      deployCMTATStandaloneWithParameter(
        this.deployerAddress.address,
        this._.address,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        'CMTAT_info',
        [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
      )
    ).to.be.revertedWithCustomError(
      this.cmtatCustomError,
      'CMTAT_AuthorizationModule_AddressZeroNotAllowed'
    )
  })
})
