const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const { deployCMTATStandalone, fixture, loadFixture } = require('../../deploymentUtils')
describe(
  'Standard - EnforcementModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATStandalone(this._.address, this.admin.address, this.deployerAddress.address)
    })

    EnforcementModuleCommon()
  }
)
