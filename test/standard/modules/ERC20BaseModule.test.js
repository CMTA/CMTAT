const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const { deployCMTATStandalone, fixture, loadFixture } = require('../../deploymentUtils')
describe(
  'Standard - ERC20BaseModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATStandalone(this._, this.admin, this.deployerAddress)
    })

    ERC20BaseModuleCommon()
  }
)
