const DebtModuleCommon = require('../../common/DebtModuleCommon')
const { deployCMTATProxy } = require('../../deploymentUtils')

contract(
  'Proxy - DebtModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    DebtModuleCommon(admin, address1, address2, address3, true)
  }
)
