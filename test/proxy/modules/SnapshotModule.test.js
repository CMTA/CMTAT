const CMTAT = artifacts.require('CMTATSnapshotProxyTest')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const SnapshotModuleCommonGlobal = require('../../common/SnapshotModuleCommon/global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleCommonRescheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleZeroPlannedSnapshot')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Proxy - SnapshotModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.flag = 5
      this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [_]
      })
    })

    SnapshotModuleMultiplePlannedTest(admin, address1, address2, address3)
    SnapshotModuleOnePlannedSnapshotTest(admin, address1, address2, address3)
    SnapshotModuleZeroPlannedSnapshotTest(admin, address1, address2, address3)
    SnapshotModuleCommonGlobal(admin, address1, address2, address3)
    SnapshotModuleCommonRescheduling(admin, address1, address2, address3)
    SnapshotModuleCommonScheduling(admin, address1, address2, address3)
    SnapshotModuleCommonUnschedule(admin, address1, address2, address3)
    SnapshotModuleCommonUnschedule(admin, address1, address2, address3)
    SnapshotModuleCommonGetNextSnapshot(admin, address1, address2, address3)
  }
)
