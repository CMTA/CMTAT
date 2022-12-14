const CMTAT = artifacts.require('CMTAT')
const BurnModuleCommon = require('../../common/BurnModuleCommon')

contract(
  'Standard - BurnModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: admin })
    })

    BurnModuleCommon(admin, address1, address2)
  }
)
