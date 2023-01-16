const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Proxy - EnforcementModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS], {
        initializer: 'initialize',
        constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS]
      })
    })

    EnforcementModuleCommon(admin, address1, address2)
  }
)
