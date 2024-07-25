const AuthorizationModuleCommon = require('../../../common/AuthorizationModule/AuthorizationModuleCommon')
const { deployCMTATStandalone, fixture, loadFixture } = require('../../../deploymentUtils')
describe(
  'Standard - AuthorizationModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATStandalone(this._, this.admin, this.deployerAddress)
    })
    AuthorizationModuleCommon()
  }
)
