const AuthorizationModuleCommon = require('../../../common/AuthorizationModule/AuthorizationModuleCommon')
const {deployCMTATStandalone} = require('../../../deploymentUtils')

contract(
  'Standard - AuthorizationModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    AuthorizationModuleCommon(admin, address1, address2)
  }
)
