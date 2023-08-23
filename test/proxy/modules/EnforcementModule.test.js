const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const { deployCMTATProxy } = require('../../deploymentUtils')

contract(
  'Proxy - EnforcementModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    EnforcementModuleCommon(admin, address1, address2, address3)
  }
)
