const CMTAT = artifacts.require('CMTAT')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const SnapshotModuleCommon = require('../../common/SnapshotModuleCommon/SnapshotModuleCommon')
const SnapshotModuleCommonRescheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonGetNextSnapshot')

contract(
  'Proxy - SnapshotModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await deployProxy(CMTAT, [true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], {
        initializer: 'initialize',
        constructorArgs: [_, true, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch']
      })
    })

    SnapshotModuleCommon(admin, address1, address2, address3)
    SnapshotModuleCommonRescheduling(admin, address1, address2, address3)
    SnapshotModuleCommonScheduling(admin, address1, address2, address3)
    SnapshotModuleCommonUnschedule(admin, address1, address2, address3)
    SnapshotModuleCommonGetNextSnapshot(admin, address1, address2, address3)
  }
)
