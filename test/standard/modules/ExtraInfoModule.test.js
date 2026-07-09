const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('Standard - ExtraInfoModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  ExtraInfoModuleCommon()
})
