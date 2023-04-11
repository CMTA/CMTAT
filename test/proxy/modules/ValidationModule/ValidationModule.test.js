const CMTAT = artifacts.require('CMTAT_PROXY')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { ZERO_ADDRESS } = require('../../../utils')
const RuleEngineMock = artifacts.require('RuleEngineMock')
const ADDRESS1_INITIAL_BALANCE = 31
const ADDRESS2_INITIAL_BALANCE = 32
const ADDRESS3_INITIAL_BALANCE = 33
contract(
  'Proxy - ValidationModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.flag = 5
      this.ruleEngineMock = await RuleEngineMock.new({ from: admin })
      this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_]
      })
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_BALANCE, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_BALANCE, { from: admin })
    })
    ValidationModuleCommon(admin, address1, address2, address3, ADDRESS1_INITIAL_BALANCE, ADDRESS2_INITIAL_BALANCE, ADDRESS3_INITIAL_BALANCE)
  }
)
