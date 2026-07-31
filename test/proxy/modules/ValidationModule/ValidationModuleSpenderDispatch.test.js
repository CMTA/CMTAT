const RuleEngineSpenderDispatchCommon = require('../../../common/ValidationModule/RuleEngineSpenderDispatchCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

describe('Proxy - ValidationModule - RuleEngine spender dispatch', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  RuleEngineSpenderDispatchCommon()
})
