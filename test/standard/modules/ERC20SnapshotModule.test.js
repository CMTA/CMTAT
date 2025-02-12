const ERC20SnapshotModuleCommonRescheduling = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonRescheduling')
const ERC20SnapshotModuleCommonScheduling = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonScheduling')
const ERC20SnapshotModuleCommonUnschedule = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonUnschedule')
const ERC20SnapshotModuleCommonGetNextSnapshot = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonGetNextSnapshot')
const ERC20SnapshotModuleMultiplePlannedTest = require('../../common/ERC20SnapshotModuleCommon/global/ERC20SnapshotModuleMultiplePlannedTest')
const ERC20SnapshotModuleOnePlannedSnapshotTest = require('../../common/ERC20SnapshotModuleCommon/global/ERC20SnapshotModuleOnePlannedSnapshotTest')
const ERC20SnapshotModuleZeroPlannedSnapshotTest = require('../../common/ERC20SnapshotModuleCommon/global/ERC20SnapshotModuleZeroPlannedSnapshot')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')

describe('Standard - ERC20SnapshotModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.transferEngineMock = await ethers.deployContract(
      'SnapshotEngineMock',
      [this.cmtat.target, this.admin]
    )
    this.cmtat.connect(this.admin).setSnapshotEngine(this.transferEngineMock)
  })
  ERC20SnapshotModuleMultiplePlannedTest()
  ERC20SnapshotModuleOnePlannedSnapshotTest()
  ERC20SnapshotModuleZeroPlannedSnapshotTest()
  ERC20SnapshotModuleCommonRescheduling()
  ERC20SnapshotModuleCommonScheduling()
  ERC20SnapshotModuleCommonUnschedule()
  ERC20SnapshotModuleCommonGetNextSnapshot()
})
