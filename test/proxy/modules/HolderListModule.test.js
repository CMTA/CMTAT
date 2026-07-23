const HolderListModuleCommon = require('../../common/HolderListModuleCommon')
const {
  deployCMTATHolderListProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')

describe('Proxy - HolderListModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATHolderListProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  HolderListModuleCommon()
})
