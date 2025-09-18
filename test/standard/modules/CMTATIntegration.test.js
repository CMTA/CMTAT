const CMTATIntegrationCommon = require('../../common/CMTATIntegrationCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('Standard - CMTATIntegrationModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  CMTATIntegrationCommon()
})
