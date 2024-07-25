const BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const { deployCMTATProxy, fixture, loadFixture } = require('../../deploymentUtils')

describe(
  'Proxy - ERC20BurnModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATProxy(this._, this.admin, this.deployerAddress)
    })

    BurnModuleCommon()
  }
)
