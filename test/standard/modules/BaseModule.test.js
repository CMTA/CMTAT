const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')
const BaseModuleCommon = require('../../common/BaseModuleCommon')

contract(
  'Standard - BaseModule',
  function ([_, owner, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(owner, _, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    BaseModuleCommon(owner, address1, address2, address3, false)
  }
)
