const RuleEngineReentrancyCommon = require('../../../common/ValidationModule/RuleEngineReentrancyCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

describe('Proxy - ValidationModule - RuleEngine reentrancy', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  RuleEngineReentrancyCommon()
})
