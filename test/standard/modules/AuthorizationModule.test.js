const CMTAT = artifacts.require('CMTAT')
const AuthorizationModuleCommon = require('../../common/AuthorizationModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Standard - AuthorizationModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: admin })
    })

    AuthorizationModuleCommon(admin, address1, address2)
  }
)
