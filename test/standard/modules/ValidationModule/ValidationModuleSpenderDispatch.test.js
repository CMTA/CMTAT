const RuleEngineSpenderDispatchCommon = require('../../../common/ValidationModule/RuleEngineSpenderDispatchCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

describe('Standard - ValidationModule - RuleEngine spender dispatch', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  RuleEngineSpenderDispatchCommon()
})
