const BaseModuleCommon = require('../../common/BaseModuleCommon')
const {deployCMTATStandalone, DEPLOYMENT_FLAG} = require('../../deploymentUtils')
contract(
  'Standard - BaseModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.flag = DEPLOYMENT_FLAG // value used in tests
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    BaseModuleCommon(admin, address1, address2, address3, false)
  }
)
