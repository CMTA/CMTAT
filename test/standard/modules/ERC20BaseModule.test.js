const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const {deployCMTATStandalone} = require('../../deploymentUtils')
contract(
  'Standard - ERC20BaseModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    ERC20BaseModuleCommon(admin, address1, address2, address3, false)
  }
)
