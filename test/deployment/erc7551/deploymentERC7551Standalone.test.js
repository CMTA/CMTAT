const { expect } = require('chai')
const {
  deployCMTATERC7551Standalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
// Core
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
// options
const ERC20CrossChainModuleCommon = require('../../common/ERC20CrossChainModuleCommon')
const ERC7551ModuleCommon = require('../../common/ERC7551ModuleCommon')
// Extensions
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
// Snapshot
const SnapshotModuleCommonRescheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleZeroPlannedSnapshot')
const SnapshotModuleSetSnapshotEngineCommon = require('../../common/SnapshotModuleCommon/SnapshotModuleSetSnapshotEngineCommon')

describe('CMTAT ERC7551 - Standalone', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATERC7551Standalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  // Core
  BaseModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()

  // options
  ERC20CrossChainModuleCommon()
  ERC7551ModuleCommon()
  // Extensions
  ERC20EnforcementModuleCommon()
  DocumentModuleCommon()
  ExtraInfoModuleCommon()

  // Snapshot
  SnapshotModuleMultiplePlannedTest()
  SnapshotModuleOnePlannedSnapshotTest()
  SnapshotModuleZeroPlannedSnapshotTest()
  SnapshotModuleCommonRescheduling()
  SnapshotModuleCommonScheduling()
  SnapshotModuleCommonUnschedule()
  SnapshotModuleCommonGetNextSnapshot()
  // Set snapshot Engine
  // SnapshotModuleSetSnapshotEngineCommon()
})
