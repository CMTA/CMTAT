const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const {deployCMTATStandalone} = require('../../../deploymentUtils')
contract(
  'Standard - ValidationModule - setRuleEngine',
  function ([_, admin, address1, fakeRuleEngine, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })
    ValidationModuleSetRuleEngineCommon(admin, address1, fakeRuleEngine)
  }
)
