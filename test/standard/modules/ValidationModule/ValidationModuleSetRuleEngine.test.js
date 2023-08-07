const CMTAT = artifacts.require('CMTAT_STANDALONE')
const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { ZERO_ADDRESS } = require('../../../utils')
contract(
  'Standard - ValidationModule - setRuleEngine',
  function ([_, admin, address1, fakeRuleEngine, deployerAddress]) {
    beforeEach(async function () {
      this.flag = 5
      const DECIMAL = 5
      this.cmtat = await CMTAT.new(_, admin, 'CMTA Token', 'CMTAT', DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: deployerAddress })
    })
    ValidationModuleSetRuleEngineCommon(admin, address1, fakeRuleEngine)
  }
)
