const {
  expectRevertCustomError
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { ZERO_ADDRESS } = require('../utils')
const {
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter,
  fixture, loadFixture 
} = require('../deploymentUtils')
describe('CMTAT - Deployment', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  })

  it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
    const DECIMAL = 0
    // Act + Assert
    await expectRevertCustomError(
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
      ),
      'CMTAT_AuthorizationModule_AddressZeroNotAllowed',
      []
    )
  })
  it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
    const DECIMAL = 0
    // Act + Assert
    await expectRevertCustomError(
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
      ),
      'CMTAT_AuthorizationModule_AddressZeroNotAllowed',
      []
    )
  })
})
