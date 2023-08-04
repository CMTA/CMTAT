const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const {deployCMTATProxy} = require('../../deploymentUtils')

contract(
  'Proxy - ERC20BaseModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    ERC20BaseModuleCommon(admin, address1, address2, address3, true)
  }
)
