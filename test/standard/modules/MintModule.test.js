const CMTAT = artifacts.require('CMTAT')
const MintModuleCommon = require('../../common/MintModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Standard - MintModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, { from: admin })
    })

    MintModuleCommon(admin, address1, address2)
  }
)
