const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const ERC20EnforcementERC7551ModuleCommon = require('../../common/ERC20EnforcementERC7551ModuleCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('Standard - ERC20EnforcementModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc7551 = true
  })

  ERC20EnforcementModuleCommon()
  ERC20EnforcementERC7551ModuleCommon()
})
