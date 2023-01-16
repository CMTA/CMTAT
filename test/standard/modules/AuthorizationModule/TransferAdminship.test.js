const CMTAT = artifacts.require('CMTAT')
const TransferAdminshipCommon = require('../../../common/AuthorizationModule/TransferAdminshipCommon')
const { ZERO_ADDRESS } = require('../../../utils')

contract(
  'Standard - TransferAdminship',
  function ([_, oldAdmin, newAdmin, attacker]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, oldAdmin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, { from: oldAdmin })
    })

    TransferAdminshipCommon(oldAdmin, newAdmin, attacker)
  }
)
