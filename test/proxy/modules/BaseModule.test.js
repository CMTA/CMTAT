const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_PROXY')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')
const { deployCMTATProxy, DEPLOYMENT_FLAG } = require('../../deploymentUtils')

contract(
  'Proxy - BaseModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.flag = DEPLOYMENT_FLAG // value used in tests
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
    })

    BaseModuleCommon(admin, address1, address2, address3, true)
  }
)
