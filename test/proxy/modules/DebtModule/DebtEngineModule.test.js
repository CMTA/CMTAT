const DebtModuleSetDebtEngineCommon = require('../../../common/DebtModule/DebtModuleSetDebtEngineCommon')
const DebtEngineModuleCommon = require('../../../common/DebtModule/DebtEngineModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Proxy - DebtModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
  })
  DebtEngineModuleCommon()
  DebtModuleSetDebtEngineCommon()
})
