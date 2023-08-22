const { expectRevertCustomError } = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js');
const { ZERO_ADDRESS } = require('../utils')
const { deployCMTATProxyWithParameter, deployCMTATStandaloneWithParameter } = require('../deploymentUtils')
contract(
  'CMTAT - Deployment',
  function ([_], admin) {
    it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
      this.flag = 5
      const DECIMAL = 0
      // Act + Assert
      await expectRevertCustomError(
        deployCMTATProxyWithParameter(admin, _, ZERO_ADDRESS, 'CMTA Token', 'CMTAT',  DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag),
        'CMTAT_AuthorizationModule_AddressZeroNotAllowed',
        []
      )
    })
    it('testCannotDeployStandaloneWithAdminSetToAddressZero', async function () {
      this.flag = 5
      const DECIMAL = 0
      // Act + Assert
      await expectRevertCustomError(
        deployCMTATStandaloneWithParameter(admin, _, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag),
        'CMTAT_AuthorizationModule_AddressZeroNotAllowed',
        []
      )
    })
  }
)
