const CMTAT = artifacts.require('CMTAT')
const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { ZERO_ADDRESS } = require('../../../utils')
contract(
  'Standard - ValidationModule - setRuleEngine',
  function ([_, admin, address1, fakeRuleEngine]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: admin })
    })
    ValidationModuleSetRuleEngineCommon(admin, address1, fakeRuleEngine)
  }
)
