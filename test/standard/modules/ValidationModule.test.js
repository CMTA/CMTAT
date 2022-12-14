const CMTAT = artifacts.require('CMTAT')
const ValidationModuleCommon = require('../../common/ValidationModuleCommon')

contract(
  'Standard - ValidationModule',
  function ([_, admin, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: admin })
    })

    ValidationModuleCommon(admin, address1, address2, address3, fakeRuleEngine)
  }
)
