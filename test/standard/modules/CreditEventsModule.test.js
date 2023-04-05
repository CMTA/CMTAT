const CMTAT = artifacts.require('CMTAT_STANDALONE')
const CreditEventsModuleCommon = require('../../common/CreditEventsModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Standard - CreditEventsModule',
  function ([_, admin, attacker, randomDeployer]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await CMTAT.new(_, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: randomDeployer })
    })

    CreditEventsModuleCommon(admin, attacker)
  }
)
