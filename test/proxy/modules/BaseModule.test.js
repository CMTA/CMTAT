const BaseModuleCommon = require('../../common/BaseModuleCommon')
const { deployCMTATProxy, DEPLOYMENT_FLAG, fixture, loadFixture } = require('../../deploymentUtils')

describe(
  'Proxy - BaseModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.flag = DEPLOYMENT_FLAG // value used in tests
      this.cmtat = await deployCMTATProxy(this._.address, this.admin.address, this.deployerAddress.address)
    })

    BaseModuleCommon()
  }
)
