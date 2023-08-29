const CreditEventsModuleCommon = require('../../common/CreditEventsModuleCommon')
const { deployCMTATProxy } = require('../../deploymentUtils')

contract(
  'Proxy - CreditEventsModule',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    CreditEventsModuleCommon(admin, attacker)
  }
)
