const ERC20CrossChainModuleCommon = require('../../common/ERC20CrossChainModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('Standard - BaseExtend', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })

  ERC20CrossChainModuleCommon()
})
