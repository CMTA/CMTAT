const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const {deployCMTATStandalone} = require('../../deploymentUtils')
contract(
  'Standard - EnforcementModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    EnforcementModuleCommon(admin, address1, address2, address3)
  })
