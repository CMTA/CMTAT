const CMTAT = artifacts.require('CMTAT_BASE')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const AuthorizationModuleCommon = require('../../common/AuthorizationModule/AuthorizationModuleCommon')

contract(
  'Proxy - AuthorizationModule',
  function ([_, owner, address1, address2]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [owner, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag])
    })

    AuthorizationModuleCommon(owner, address1, address2)
  }
)
