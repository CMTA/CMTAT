const DebtModuleCommon = require('../../common/DebtModuleCommon')
const { deployCMTATStandalone } = require('../../deploymentUtils')
contract(
  'Standard - DebtModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    DebtModuleCommon(admin, address1, address2, address3, false)
  }
)
