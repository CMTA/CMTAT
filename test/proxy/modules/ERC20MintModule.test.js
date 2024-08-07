const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const { deployCMTATProxy, fixture, loadFixture } = require('../../deploymentUtils')

describe(
  'Proxy - ERC20MintModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATProxy(this._.address, this.admin.address, this.deployerAddress.address)
    })

    ERC20MintModuleCommon()
  }
)
