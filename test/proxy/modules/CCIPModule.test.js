const CCIPModuleCommon = require('../../common/CCIPModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')

describe('Proxy - CCIPModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  CCIPModuleCommon()
})
