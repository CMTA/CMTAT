const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Proxy - BaseModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS], {
        initializer: 'initialize',
        constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS]
      })
    })

    BaseModuleCommon(admin, address1, address2, address3, true)
  }
)
