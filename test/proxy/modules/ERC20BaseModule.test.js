const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_BASE')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')

contract(
  'Proxy - ERC20BaseModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag])
    })

    ERC20BaseModuleCommon(admin, address1, address2, address3)
  }
)
