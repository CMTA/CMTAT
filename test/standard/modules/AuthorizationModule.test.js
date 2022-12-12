const CMTAT = artifacts.require('CMTAT')
const AuthorizationModuleCommon = require('../../common/AuthorizationModuleCommon')

contract(
  'Standard - AuthorizationModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: admin })
    })

    AuthorizationModuleCommon(admin, address1, address2)
  }
)
