const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleCommon')
const ValidationModuleCommonCore = require('../../../common/ValidationModule/ValidationModuleCommonCore')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Standard - ValidationModule', function () {
  beforeEach(async function () {
    this.ADDRESS1_INITIAL_BALANCE = 31n
    this.ADDRESS2_INITIAL_BALANCE = 32n
    this.ADDRESS3_INITIAL_BALANCE = 33n
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
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
  ValidationModuleCommonCore()
})
