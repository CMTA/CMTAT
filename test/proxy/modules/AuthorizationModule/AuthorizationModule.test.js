const CMTAT = artifacts.require('CMTAT_PROXY')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const AuthorizationModuleCommon = require('../../../common/AuthorizationModule/AuthorizationModuleCommon')
const { ZERO_ADDRESS } = require('../../../utils')

contract(
  'Proxy - AuthorizationModule',
  function ([_, owner, address1, address2]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_]
      })
    })

    AuthorizationModuleCommon(owner, address1, address2)
  }
)
