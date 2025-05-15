const ValidationModuleCommon = require('../ValidationModuleCommon')
const ValidationModuleSetRuleEngineCommon = require('../ValidationModuleSetRuleEngineCommon')
const {
  deployCMTATERC1363Proxy,
  deployCMTATProxy,
  deployCMTATProxyWithParameter,
  DEPLOYMENT_DECIMAL,
  TERMS,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
const { ZERO_ADDRESS } = require('../../../utils')
function ValidationModuleProxyCommon () {
  context('Proxy - ValidationModule', function () {
    beforeEach(async function () {
      this.ADDRESS1_INITIAL_BALANCE = 17n
      this.ADDRESS2_INITIAL_BALANCE = 18n
      this.ADDRESS3_INITIAL_BALANCE = 19n
      Object.assign(this, await loadFixture(fixture))
      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [this.admin])
      if (!this.CMTATERC1363) {
        this.cmtat = await deployCMTATProxy(
          this._.address,
          this.admin.address,
          this.deployerAddress.address
        )
      } else {
        this.cmtat = await deployCMTATERC1363Proxy(
          this._.address,
          this.admin.address,
          this.deployerAddress.address
        )
      }
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, this.ADDRESS1_INITIAL_BALANCE)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, this.ADDRESS2_INITIAL_BALANCE)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, this.ADDRESS3_INITIAL_BALANCE)
    })
    ValidationModuleCommon()
  })
  context('Proxy - ValidationModule - Constructor', function () {
    beforeEach(async function () {
      this.ADDRESS1_INITIAL_BALANCE = 17n
      this.ADDRESS2_INITIAL_BALANCE = 18n
      this.ADDRESS3_INITIAL_BALANCE = 19n
      Object.assign(this, await loadFixture(fixture))
      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [this.admin])
      this.definedAtDeployment = true
      this.cmtat = await deployCMTATProxyWithParameter(
        this.deployerAddress.address,
        this._.address,
        this.admin.address,
        'CMTA Token',
        'CMTAT',
        DEPLOYMENT_DECIMAL,
        'CMTAT_ISIN',
        TERMS,
        'CMTAT_info',
        [this.ruleEngineMock.target, ZERO_ADDRESS, ZERO_ADDRESS]
      )
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, this.ADDRESS1_INITIAL_BALANCE)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, this.ADDRESS2_INITIAL_BALANCE)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, this.ADDRESS3_INITIAL_BALANCE)
    })
    ValidationModuleCommon()
  })
  context('Proxy - ValidationModule - setRuleEngine', function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture))
      if (!this.CMTATERC1363) {
        this.cmtat = await deployCMTATProxy(
          this._.address,
          this.admin.address,
          this.deployerAddress.address
        )
      } else {
        this.cmtat = await deployCMTATERC1363Proxy(
          this._.address,
          this.admin.address,
          this.deployerAddress.address
        )
      }
      this.ruleEngine = await ethers.deployContract('RuleEngineMock', [this.admin])
    })
    ValidationModuleSetRuleEngineCommon()
  })
}
module.exports = ValidationModuleProxyCommon
