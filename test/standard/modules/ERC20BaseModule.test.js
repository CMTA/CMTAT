const CMTAT = artifacts.require('CMTAT_STANDALONE')
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Standard - ERC20BaseModule',
  function ([_, admin, address1, address2, address3, randomDeployer]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await CMTAT.new(_, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: randomDeployer })
    })

    ERC20BaseModuleCommon(admin, address1, address2, address3, false)
  }
)
