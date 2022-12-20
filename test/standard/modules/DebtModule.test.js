const CMTAT = artifacts.require('CMTAT')
const DebtModuleCommon = require('../../common/DebtModuleCommon')

contract(
  'Standard - DebtModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: admin })
    })

    DebtModuleCommon(admin, address1, address2, address3, false)
  }
)
