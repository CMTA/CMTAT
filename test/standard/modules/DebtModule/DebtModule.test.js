const DebtModuleSetDebtEngineCommon = require('../../../common/DebtModule/DebtModuleSetDebtEngineCommon')
const DebtModuleCommon = require('../../../common/DebtModule/DebtModuleCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Standard - DebtModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
  })
  DebtModuleCommon()
  DebtModuleSetDebtEngineCommon()
})
