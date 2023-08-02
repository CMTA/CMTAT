const AuthorizationModuleCommon = require('../../../common/AuthorizationModule/AuthorizationModuleCommon')
const {deployCMTATProxy} = require('../../../deploymentUtils')

contract(
  'Proxy - AuthorizationModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    AuthorizationModuleCommon(admin, address1, address2)
  }
)
