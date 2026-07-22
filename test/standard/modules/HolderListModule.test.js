const HolderListModuleCommon = require('../../common/HolderListModuleCommon')
const {
  deployCMTATHolderListStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')

describe('Standard - HolderListModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATHolderListStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  HolderListModuleCommon()
})
