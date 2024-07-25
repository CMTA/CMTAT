const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { deployCMTATStandalone } = require('../../../deploymentUtils')
let [_, admin, address1, fakeRuleEngine, deployerAddress] =  new Array(0);
contract(
  'Standard - ValidationModule - setRuleEngine',
  function ([_, admin, address1, fakeRuleEngine, deployerAddress]) {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      [_, admin, address1, fakeRuleEngine, deployerAddress] = await ethers.getSigners();
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })
    ValidationModuleSetRuleEngineCommon(admin, address1, fakeRuleEngine)
  }
)
