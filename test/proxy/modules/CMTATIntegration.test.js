const CMTATIntegrationCommon = require('../../common/CMTATIntegrationCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('Proxy - CMTATIntegration', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  CMTATIntegrationCommon()
})
