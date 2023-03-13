const CMTAT = artifacts.require('CMTAT_STANDALONE')
const BurnModuleCommon = require('../../common/BurnModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Standard - BurnModule',
  function ([_, admin, address1, address2, randomDeployer]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await CMTAT.new(_, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag, { from: randomDeployer })
    })

    BurnModuleCommon(admin, address1, address2)
  }
)
