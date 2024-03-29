const {
  expectRevertCustomError
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { time } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS } = require('../utils')
const {
  deployCMTATProxyWithParameter,
  deployCMTATStandaloneWithParameter
} = require('../deploymentUtils')
contract('CMTAT - Deployment', function ([_], deployer) {
  it('testCannotDeployProxyWithAdminSetToAddressZero', async function () {
    const delayTime = BigInt(time.duration.days(3))
    this.flag = 5
    const DECIMAL = 0
    // Act + Assert
    await expectRevertCustomError(
      deployCMTATProxyWithParameter(
        deployer,
        _,
        ZERO_ADDRESS,
        delayTime,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        ZERO_ADDRESS,
        'CMTAT_info',
        this.flag
      ),
      'AccessControlInvalidDefaultAdmin',
      [ZERO_ADDRESS]
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
        web3.utils.toBN(time.duration.days(3)),
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        ZERO_ADDRESS,
        'CMTAT_info',
        this.flag
      ),
      'AccessControlInvalidDefaultAdmin',
      [ZERO_ADDRESS]
    )
  })
})
