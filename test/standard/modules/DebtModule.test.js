const CMTAT = artifacts.require('CMTAT_STANDALONE')
const DebtModuleCommon = require('../../common/DebtModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Standard - DebtModule',
  function ([_, admin, address1, address2, address3, randomDeployer]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await CMTAT.new(_, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: randomDeployer })
    })

    DebtModuleCommon(admin, address1, address2, address3, false)
  }
)
