const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { PAUSER_ROLE } = require('../../utils')
const chai = require('chai')
const expect = chai.expect
const should = chai.should()
const CMTAT = artifacts.require('CMTAT')
const AuthorizationModuleCommon = require('../../common/AuthorizationModuleCommon')

contract(
  'AuthorizationModule',
  function ([_, owner, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, { from: owner })
      await this.cmtat.initialize(owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    AuthorizationModuleCommon(owner, address1, address2)
  }
)
