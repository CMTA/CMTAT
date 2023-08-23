const BurnModuleCommon = require('../../common/BurnModuleCommon')
const { deployCMTATStandalone } = require('../../deploymentUtils')
contract(
  'Standard - BurnModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    BurnModuleCommon(admin, address1, address2)
  }
)
