const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { deployCMTATProxy, fixture, loadFixture } = require('../../../deploymentUtils')

contract(
  'Proxy - ValidationModule - setRuleEngine',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATProxy(this._, this.admin, this.deployerAddress)
    })
    ValidationModuleSetRuleEngineCommon()
  }
)
