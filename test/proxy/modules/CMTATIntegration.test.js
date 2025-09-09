const CMTATIntegrationCommon = require('../../common/CMTATIntegrationCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const VALUE1 = 20n
describe('Proxy - ERC20BurnModule', function () {
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
