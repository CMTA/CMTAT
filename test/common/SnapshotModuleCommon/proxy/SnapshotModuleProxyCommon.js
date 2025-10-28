const SnapshotModuleCommonRescheduling = require('../SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../global/SnapshotModuleZeroPlannedSnapshot')
const SnapshotModuleSetSnapshotEngineCommon = require('../SnapshotModuleSetSnapshotEngineCommon')

const {
  deployCMTATProxy,
  deployCMTATProxyWithParameter,
  fixture,
  loadFixture,
  DEPLOYMENT_DECIMAL,
  TERMS
} = require('../../../deploymentUtils')
const { ZERO_ADDRESS } = require('../../../utils')
function SnapshotModuleProxyCommon () {
  context('Proxy - SnapshotModule', function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture))
      if (!this.CMTATAlreadyDeployed) {
        this.cmtat = await deployCMTATProxy(
          this._.address,
          this.admin.address,
          this.deployerAddress.address
        )
      }
      this.transferEngineMock = await ethers.deployContract(
        'SnapshotEngineMock',
        [this.cmtat.target, this.admin]
      )
    })
    SnapshotModuleMultiplePlannedTest()
    SnapshotModuleOnePlannedSnapshotTest()
    SnapshotModuleZeroPlannedSnapshotTest()
    SnapshotModuleCommonRescheduling()
    SnapshotModuleCommonScheduling()
    SnapshotModuleCommonUnschedule()
    SnapshotModuleCommonGetNextSnapshot()
    // Set snapshot Engine
    SnapshotModuleSetSnapshotEngineCommon
  })
  context('Proxy - SnapshotModule - Constructor', function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture))
      this.transferEngineMock = await ethers.deployContract(
        'SnapshotEngineMock',
        [ZERO_ADDRESS, this.admin]
      )
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
        [ZERO_ADDRESS, this.transferEngineMock.target, ZERO_ADDRESS]
      )
      this.transferEngineMock.setERC20(this.cmtat)
    })
    SnapshotModuleMultiplePlannedTest()
    SnapshotModuleOnePlannedSnapshotTest()
    SnapshotModuleZeroPlannedSnapshotTest()
    SnapshotModuleCommonRescheduling()
    SnapshotModuleCommonScheduling()
    SnapshotModuleCommonUnschedule()
    SnapshotModuleCommonGetNextSnapshot()
    // Set snapshot Engine
    SnapshotModuleSetSnapshotEngineCommon()
  })
}
module.exports = SnapshotModuleProxyCommon
