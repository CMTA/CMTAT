const CMTAT = artifacts.require('CMTAT')
const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleCommon')
const { ZERO_ADDRESS } = require('../../../utils')
const ADDRESS1_INITIAL_BALANCE = 31
const ADDRESS2_INITIAL_BALANCE = 32
const ADDRESS3_INITIAL_BALANCE = 33
contract(
  'Standard - ValidationModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, { from: admin })
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_BALANCE, { from: admin })
    })
    ValidationModuleCommon(admin, address1, address2, address3, ADDRESS1_INITIAL_BALANCE, ADDRESS2_INITIAL_BALANCE, ADDRESS3_INITIAL_BALANCE)
  }
)