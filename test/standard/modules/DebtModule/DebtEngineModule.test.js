const DebtModuleSetDebtEngineCommon = require('../../../common/DebtModule/DebtModuleSetDebtEngineCommon')
const DebtEngineModuleCommon = require('../../../common/DebtModule/DebtEngineModuleCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Standard - DebtEngineModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
  })
  DebtEngineModuleCommon()
  DebtModuleSetDebtEngineCommon()
})
