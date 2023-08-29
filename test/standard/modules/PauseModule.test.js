const PauseModuleCommon = require('../../common/PauseModuleCommon')
const { deployCMTATStandalone } = require('../../deploymentUtils')
contract(
  'Standard - PauseModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
      // Mint tokens to test the transfer
      await this.cmtat.mint(address1, 20, {
        from: admin
      })
    })

    PauseModuleCommon(admin, address1, address2, address3)
  }
)
