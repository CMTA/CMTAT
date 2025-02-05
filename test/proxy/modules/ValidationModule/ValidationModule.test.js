const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

describe('Proxy - ValidationModule', function () {
  beforeEach(async function () {
    this.ADDRESS1_INITIAL_BALANCE = 17n
    this.ADDRESS2_INITIAL_BALANCE = 18n
    this.ADDRESS3_INITIAL_BALANCE = 19n
    Object.assign(this, await loadFixture(fixture))
    this.ruleEngineMock = await ethers.deployContract('RuleEngineMock')
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
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
