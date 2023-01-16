const CMTAT = artifacts.require('CMTAT')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const RuleEngineMock = artifacts.require('RuleEngineMock')
const ADDRESS1_INITIAL_BALANCE = 17
const ADDRESS2_INITIAL_BALANCE = 18
const ADDRESS3_INITIAL_BALANCE = 19
contract(
  'Proxy - ValidationModule - Constructor',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.ruleEngineMock = await RuleEngineMock.new({ from: admin })
      this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', this.ruleEngineMock.address], {
        initializer: 'initialize',
        constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', this.ruleEngineMock.address]
      })
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_BALANCE, { from: admin })
    })
    ValidationModuleCommon(admin, address1, address2, address3, ADDRESS1_INITIAL_BALANCE, ADDRESS2_INITIAL_BALANCE, ADDRESS3_INITIAL_BALANCE)
  }
)