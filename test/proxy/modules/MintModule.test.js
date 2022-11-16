const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const MintModuleCommon = require('../../common/MintModuleCommon')
contract(
  'Proxy - MintModule',
  function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], { initializer: 'initialize', constructorArgs: [_] })
    })

    MintModuleCommon(owner, address1, address2)
  }
)
