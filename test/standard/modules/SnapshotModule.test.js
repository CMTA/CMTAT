const CMTAT = artifacts.require('CMTATSnapshotStandaloneTest')
const SnapshotModuleCommonRescheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleZeroPlannedSnapshot')
const { deployCMTATStandaloneWithSnapshot } = require('../../deploymentUtils')
contract(
  'Standard - SnapshotModule',
  function ([_, admin, address1, address2, address3, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATStandaloneWithSnapshot(_, admin, deployerAddress)
    })
    SnapshotModuleMultiplePlannedTest(admin, address1, address2, address3)
    SnapshotModuleOnePlannedSnapshotTest(admin, address1, address2, address3)
    SnapshotModuleZeroPlannedSnapshotTest(admin, address1, address2, address3)
    SnapshotModuleCommonRescheduling(admin, address1, address2, address3)
    SnapshotModuleCommonScheduling(admin, address1, address2, address3)
    SnapshotModuleCommonUnschedule(admin, address1, address2, address3)
    SnapshotModuleCommonGetNextSnapshot(admin, address1, address2, address3)
  }
)
