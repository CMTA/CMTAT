const SnapshotModuleCommonRescheduling = require('../SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../global/SnapshotModuleZeroPlannedSnapshot')
const SnapshotModuleSetSnapshotEngineCommon = require('../SnapshotModuleSetSnapshotEngineCommon')

const {
  deployCMTATSnapshotProxy,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
function SnapshotModuleProxyCommon () {
  context('Proxy - SnapshotModule', function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture))
      if (!this.CMTATAlreadyDeployed) {
        this.cmtat = await deployCMTATSnapshotProxy(
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
    SnapshotModuleSetSnapshotEngineCommon()
  })
}
module.exports = SnapshotModuleProxyCommon
