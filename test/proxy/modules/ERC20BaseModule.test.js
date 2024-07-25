const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const { deployCMTATProxy, fixture, loadFixture } = require('../../deploymentUtils')

describe(
  'Proxy - ERC20BaseModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATProxy(this._, this.admin, this.deployerAddress)
    })

    ERC20BaseModuleCommon()
  }
)
