const PauseModuleCommon = require('../../common/PauseModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')

describe('Proxy - PauseModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    // Mint tokens to test the transfer
    await this.cmtat.connect(this.admin).mint(this.address1, 20)
  })
  PauseModuleCommon()
})
