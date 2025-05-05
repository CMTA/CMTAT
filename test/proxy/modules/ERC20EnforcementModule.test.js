const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')

describe('Proxy - ERC20EnforcementModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  ERC20EnforcementModuleCommon()
})
