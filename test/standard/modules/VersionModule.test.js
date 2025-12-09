const VersionModuleCommon = require('../../common/VersionModuleCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('Standard - VersionModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  VersionModuleCommon()
})
