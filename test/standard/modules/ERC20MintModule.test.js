const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const { deployCMTATStandalone } = require('../../deploymentUtils')
contract(
  'Standard - ERC20MintModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    ERC20MintModuleCommon(admin, address1, address2)
  }
)
