const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { ENFORCER_ROLE } = require('../../utils')

const CMTAT = artifacts.require('CMTAT')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')

contract(
  'Standard - EnforcementModule',
  function ([_, admin, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: admin })
    })

    EnforcementModuleCommon(admin, address1, address2)
  })
