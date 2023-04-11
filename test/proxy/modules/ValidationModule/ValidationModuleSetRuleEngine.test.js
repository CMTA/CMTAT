const CMTAT = artifacts.require('CMTAT_PROXY')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { ZERO_ADDRESS } = require('../../../utils')
contract(
  'Proxy - ValidationModule - setRuleEngine',
  function ([_, admin, address1, fakeRuleEngine]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_]
      })
    })
    ValidationModuleSetRuleEngineCommon(admin, address1, fakeRuleEngine)
  }
)
