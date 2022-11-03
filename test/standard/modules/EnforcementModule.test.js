const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { ENFORCER_ROLE } = require('../../utils')

const CMTAT = artifacts.require('CMTAT')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')

contract(
  'EnforcementModule',
  function ([_, owner, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, { from: owner })
      await this.cmtat.initialize(owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    EnforcementModuleCommon(owner, address1, address2)
  })