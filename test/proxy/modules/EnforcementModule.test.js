const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const { deployCMTATProxy, fixture, loadFixture } = require('../../deploymentUtils')

describe(
  'Proxy - EnforcementModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATProxy(this._, this.admin, this.deployerAddress)
    })

    EnforcementModuleCommon()
  }
)
