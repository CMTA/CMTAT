const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')
const RuleEngineMock = artifacts.require('RuleEngineMock')
const ValidationModuleCommon = require('../../common/ValidationModuleCommon')

contract(
  'ValidationModule',
  function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, { from: owner })
      await this.cmtat.initialize(owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    ValidationModuleCommon(owner, address1, address2, address3, fakeRuleEngine)
  }
)
