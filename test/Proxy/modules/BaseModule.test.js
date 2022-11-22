const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { should } = require('chai').should()
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
contract(
  'BaseModule',
  function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [owner, _, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], { initializer: 'initialize', constructorArgs: [owner, _, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'] })
    })

    BaseModuleCommon(owner, address1, address2, address3)
  }
)
