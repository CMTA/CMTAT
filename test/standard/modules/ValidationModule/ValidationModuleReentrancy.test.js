const RuleEngineReentrancyCommon = require('../../../common/ValidationModule/RuleEngineReentrancyCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

describe('Standard - ValidationModule - RuleEngine reentrancy', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  RuleEngineReentrancyCommon()
})
