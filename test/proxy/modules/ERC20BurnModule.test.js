const BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const { deployCMTATProxy } = require('../../deploymentUtils')

contract(
  'Proxy - BurnModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    BurnModuleCommon(admin, address1, address2, address3)
  }
)
