const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const MintModuleCommon = require('../../common/MintModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Proxy - MintModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS], {
        initializer: 'initialize',
        constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS]
      })
    })

    MintModuleCommon(admin, address1, address2)
  }
)
