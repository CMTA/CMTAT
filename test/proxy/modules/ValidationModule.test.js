const CMTAT = artifacts.require('CMTAT')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const ValidationModuleCommon = require('../../common/ValidationModuleCommon')

contract(
  'Proxy - ValidationModule',
  function ([_, admin, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], {
        initializer: 'initialize',
        constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch']
      })
    })
    ValidationModuleCommon(admin, address1, address2, address3, fakeRuleEngine)
  }
)
