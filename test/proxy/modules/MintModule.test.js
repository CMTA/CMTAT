const CMTAT = artifacts.require('CMTAT_PROXY')
const MintModuleCommon = require('../../common/MintModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')
const {deployCMTATProxy} = require('../../deploymentUtils')

contract(
  'Proxy - MintModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    MintModuleCommon(admin, address1, address2)
  }
)
