const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleCommon')
const {
  deployCMTATStandaloneWithParameter, fixture, loadFixture
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe(
  'Standard - ValidationModule - Constructor',
  function () {
    beforeEach(async function () {
      this.ADDRESS1_INITIAL_BALANCE = 17n
      this.ADDRESS2_INITIAL_BALANCE = 18n
      this.ADDRESS3_INITIAL_BALANCE = 19n
      Object.assign(this, await loadFixture(fixture));
      this.flag = 5
      const DECIMAL = 0
      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock')
      this.cmtat = await deployCMTATStandaloneWithParameter(
        this.deployerAddress.address,
        this._.address,
        this.admin.address,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        this.ruleEngineMock,
        'CMTAT_info',
        this.flag
      )
      await this.cmtat.connect(this.admin).mint(this.address1, this.ADDRESS1_INITIAL_BALANCE)
      await this.cmtat.connect(this.admin).mint(this.address2, this.ADDRESS2_INITIAL_BALANCE)
      await this.cmtat.connect(this.admin).mint(this.address3, this.ADDRESS3_INITIAL_BALANCE)
    })
    ValidationModuleCommon()
  }
)
