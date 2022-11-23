const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { BURNER_ROLE, ZERO_ADDRESS } = require('../../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')
const BurnModuleCommon = require('../../common/BurnModuleCommon')

contract(
  'BurnModule',
  function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(owner, _, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    BurnModuleCommon(owner, address1, address2)
  }
)
