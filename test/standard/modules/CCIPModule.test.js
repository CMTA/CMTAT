const CCIPModuleCommon = require('../../common/CCIPModuleCommon')
const {
  deployCMTATStandalone,
  DEPLOYMENT_FLAG,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('Standard - CCIPModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  CCIPModuleCommon()
})
