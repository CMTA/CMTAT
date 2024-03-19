const {
  expectRevertCustomError
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { time } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS } = require('../utils')
const {
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter
} = require('../deploymentUtils')
contract('CMTAT - Deployment', function ([_], deployer, address1, address2) {
  it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
    this.flag = 5
    const DECIMAL = 0
    // Act + Assert
    await expectRevertCustomError(
      deployCMTATProxyWithParameter(
        deployer,
        _,
        ZERO_ADDRESS,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        ZERO_ADDRESS,
        'CMTAT_info',
        this.flag
      ),
      'CMTAT_AuthorizationModule_AddressZeroNotAllowed',
      []
    )
  })
  it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
    this.flag = 5
    const DECIMAL = 0
    // Act + Assert
    await expectRevertCustomError(
      deployCMTATStandaloneWithParameter(
        deployer,
        _,
        ZERO_ADDRESS,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        ZERO_ADDRESS,
        'CMTAT_info',
        this.flag
      ),
      'CMTAT_AuthorizationModule_AddressZeroNotAllowed',
      []
    )
  })
})
