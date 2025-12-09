const { expect } = require('chai')
const {
  deployCMTATUUPSProxy,
  fixture,
  loadFixture
} = require('../deploymentUtils')
// Core
const ERC20BaseModuleCommon = require('../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../common/EnforcementModuleCommon')
const VersionModuleCommon = require('../common/VersionModuleCommon')
const PauseModuleCommon = require('../common/PauseModuleCommon')
// Extensions
const ERC20EnforcementModuleCommon = require('../common/ERC20EnforcementModuleCommon')
const DocumentModuleCommon = require('../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../common/ExtraInfoModuleCommon')
// options
const ERC20CrossChainModuleCommon = require('../common/ERC20CrossChainModuleCommon')
const CCIPModuleCommon = require('../common/CCIPModuleCommon')
// Snapshot
const SnapshotModuleCommonRescheduling = require('../common/SnapshotModuleCommon/SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../common/SnapshotModuleCommon/SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../common/SnapshotModuleCommon/SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../common/SnapshotModuleCommon/SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../common/SnapshotModuleCommon/global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../common/SnapshotModuleCommon/global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../common/SnapshotModuleCommon/global/SnapshotModuleZeroPlannedSnapshot')
const SnapshotModuleSetSnapshotEngineCommon = require('../common/SnapshotModuleCommon/SnapshotModuleSetSnapshotEngineCommon')

const VALUE = 20n
describe('CMTAT UUPS', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATUUPSProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.erc1404 = true
  })
  // Core
  VersionModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()

  // Extensions
  ERC20EnforcementModuleCommon()
  DocumentModuleCommon()
  ExtraInfoModuleCommon()

  // options
  ERC20CrossChainModuleCommon()
  CCIPModuleCommon()

  // options
  ERC20CrossChainModuleCommon()

  // Snapshot
  SnapshotModuleMultiplePlannedTest()
  SnapshotModuleOnePlannedSnapshotTest()
  SnapshotModuleZeroPlannedSnapshotTest()
  SnapshotModuleCommonRescheduling()
  SnapshotModuleCommonScheduling()
  SnapshotModuleCommonUnschedule()
  SnapshotModuleCommonGetNextSnapshot()
})
