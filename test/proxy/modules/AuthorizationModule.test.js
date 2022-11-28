const CMTAT = artifacts.require('CMTAT')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const AuthorizationModuleCommon = require('../../common/AuthorizationModuleCommon')

contract(
  'Proxy - AuthorizationModule',
  function ([_, owner, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [true, owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], {
        initializer: 'initialize',
        constructorArgs: [_, true, owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch']
      })
    })

    AuthorizationModuleCommon(owner, address1, address2)
  }
)
