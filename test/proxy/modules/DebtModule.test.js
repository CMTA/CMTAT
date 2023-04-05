const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_PROXY')
const DebtModuleCommon = require('../../common/DebtModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Proxy - DebtModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_]
      })
    })

    DebtModuleCommon(admin, address1, address2, address3, true)
  }
)
