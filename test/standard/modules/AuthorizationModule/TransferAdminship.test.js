const CMTAT = artifacts.require('CMTAT')
const TransferAdminshipCommon = require('../../../common/AuthorizationModule/TransferAdminshipCommon')
const { ZERO_ADDRESS } = require('../../../utils')

contract(
  'Standard - TransferAdminship',
  function ([_, oldAdmin, newAdmin, attacker, randomDeployer]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await CMTAT.new(_, false, oldAdmin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: randomDeployer })
    })

    TransferAdminshipCommon(oldAdmin, newAdmin, attacker)
  }
)
