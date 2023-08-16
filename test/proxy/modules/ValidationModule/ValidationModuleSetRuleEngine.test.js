const CMTAT = artifacts.require('CMTAT_PROXY')
const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { deployCMTATProxy } = require('../../../deploymentUtils')

contract(
  'Proxy - ValidationModule - setRuleEngine',
  function ([_, admin, address1, fakeRuleEngine, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })
    ValidationModuleSetRuleEngineCommon(admin, address1, fakeRuleEngine)
  }
)
