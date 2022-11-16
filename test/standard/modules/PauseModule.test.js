const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { PAUSER_ROLE } = require('../../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')
const PauseModuleCommon = require('../../common/PauseModuleCommon')

contract('Standard - PauseModule', function ([_, owner, address1, address2, address3]) {
  beforeEach(async function () {
    this.cmtat = await CMTAT.new(_, { from: owner })
    await this.cmtat.initialize(owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    // Mint tokens to test the transfer
    await this.cmtat.mint(address1, 20, {
      from: owner
    })
  })

  PauseModuleCommon(owner, address1, address2, address3)
})
