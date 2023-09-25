const { time } = require('@openzeppelin/test-helpers')
const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleCommon')
const RuleEngineMock = artifacts.require('RuleEngineMock')
const {
  deployCMTATStandaloneWithParameter
} = require('../../../deploymentUtils')
const ADDRESS1_INITIAL_BALANCE = 17
const ADDRESS2_INITIAL_BALANCE = 18
const ADDRESS3_INITIAL_BALANCE = 19
contract(
  'Standard - ValidationModule - Constructor',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.flag = 5
      const DECIMAL = 0
      this.ruleEngineMock = await RuleEngineMock.new({ from: admin })
      const delayTime = BigInt(time.duration.days(3))
      this.cmtat = await deployCMTATStandaloneWithParameter(
        deployerAddress,
        _,
        admin,
        delayTime,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        this.ruleEngineMock.address,
        'CMTAT_info',
        this.flag
      )
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_BALANCE, {
        from: admin
      })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_BALANCE, {
        from: admin
      })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_BALANCE, {
        from: admin
      })
    })
    ValidationModuleCommon(
      admin,
      address1,
      address2,
      address3,
      ADDRESS1_INITIAL_BALANCE,
      ADDRESS2_INITIAL_BALANCE,
      ADDRESS3_INITIAL_BALANCE
    )
  }
)
