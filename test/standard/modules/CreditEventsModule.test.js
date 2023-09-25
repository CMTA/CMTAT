const CreditEventsModuleCommon = require('../../common/CreditEventsModuleCommon')
const { deployCMTATStandalone } = require('../../deploymentUtils')
contract(
  'Standard - CreditEventsModule',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    CreditEventsModuleCommon(admin, attacker)
  }
)
