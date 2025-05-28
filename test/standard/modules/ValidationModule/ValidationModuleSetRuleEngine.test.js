const ValidationModuleSetRuleEngineCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Standard - ValidationModule - setRuleEngine', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  ValidationModuleSetRuleEngineCommon()
})
