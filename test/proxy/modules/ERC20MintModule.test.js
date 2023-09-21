const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const { deployCMTATProxy } = require('../../deploymentUtils')

contract(
  'Proxy - MintModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    ERC20MintModuleCommon(admin, address1, address2)
  }
)
