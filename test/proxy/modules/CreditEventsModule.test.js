const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const CreditEventsModuleCommon = require('../../common/CreditEventsModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Proxy - CreditEventsModule',
  function ([_, admin, attacker]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag]
      })
    })

    CreditEventsModuleCommon(admin, attacker)
  }
)