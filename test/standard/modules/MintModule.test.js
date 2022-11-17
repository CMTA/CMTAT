const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')
const MintModuleCommon = require('../../common/MintModuleCommon')

contract(
  'MintModule',
  function ([_, owner, address1, address2]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, { from: owner })
      await this.cmtat.initialize(owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    MintModuleCommon(owner, address1, address2)
  }
)
