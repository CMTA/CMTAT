const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_BASE')
const MintModuleCommon = require('../../common/MintModuleCommon')

contract(
  'Proxy - MintModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag])
    })

    MintModuleCommon(admin, address1, address2)
  }
)
