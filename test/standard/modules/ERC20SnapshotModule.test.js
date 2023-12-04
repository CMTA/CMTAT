const ERC20SnapshotModuleCommonRescheduling = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonRescheduling')
const ERC20SnapshotModuleCommonScheduling = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonScheduling')
const ERC20SnapshotModuleCommonUnschedule = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonUnschedule')
const ERC20SnapshotModuleCommonGetNextSnapshot = require('../../common/ERC20SnapshotModuleCommon/ERC20SnapshotModuleCommonGetNextSnapshot')
const ERC20SnapshotModuleMultiplePlannedTest = require('../../common/ERC20SnapshotModuleCommon/global/ERC20SnapshotModuleMultiplePlannedTest')
const ERC20SnapshotModuleOnePlannedSnapshotTest = require('../../common/ERC20SnapshotModuleCommon/global/ERC20SnapshotModuleOnePlannedSnapshotTest')
const ERC20SnapshotModuleZeroPlannedSnapshotTest = require('../../common/ERC20SnapshotModuleCommon/global/ERC20SnapshotModuleZeroPlannedSnapshot')
const { deployCMTATStandaloneWithSnapshot } = require('../../deploymentUtils')
contract(
  'Standard - SnapshotModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandaloneWithSnapshot(
        _,
        admin,
        deployerAddress
      )
    })
    ERC20SnapshotModuleMultiplePlannedTest(admin, address1, address2, address3)
    ERC20SnapshotModuleOnePlannedSnapshotTest(admin, address1, address2, address3)
    ERC20SnapshotModuleZeroPlannedSnapshotTest(admin, address1, address2, address3)
    ERC20SnapshotModuleCommonRescheduling(admin, address1, address2, address3)
    ERC20SnapshotModuleCommonScheduling(admin, address1, address2, address3)
    ERC20SnapshotModuleCommonUnschedule(admin, address1, address2, address3)
    ERC20SnapshotModuleCommonGetNextSnapshot(admin, address1, address2, address3)
  }
)
