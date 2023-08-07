const MintModuleCommon = require('../../common/MintModuleCommon')
const { deployCMTATStandalone } = require('../../deploymentUtils')
contract(
  'Standard - MintModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandalone(_, admin, deployerAddress)
    })

    MintModuleCommon(admin, address1, address2)
  }
)
