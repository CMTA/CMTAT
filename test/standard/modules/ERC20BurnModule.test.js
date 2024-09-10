const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const { deployCMTATStandalone, fixture, loadFixture } = require('../../deploymentUtils')
describe(
  'Standard - ERC20BurnModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATStandalone(this._.address, this.admin.address, this.deployerAddress.address)
    })

    ERC20BurnModuleCommon()
  }
)
