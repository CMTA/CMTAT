const { expect } = require('chai')
const {
  deployCMTATDebtEngineStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
const { ZERO_ADDRESS } = require('../../utils')
// Core
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const VersionModuleCommon = require('../../common/VersionModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
// Extensions
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
const DebtModuleSetDebtEngineCommon = require('../../common/DebtModule/DebtModuleSetDebtEngineCommon')
const DebtEngineModuleCommon = require('../../common/DebtModule/DebtEngineModuleCommon')
// Snapshot
const SnapshotModuleCommonRescheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../../common/SnapshotModuleCommon/SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../../common/SnapshotModuleCommon/global/SnapshotModuleZeroPlannedSnapshot')
const SnapshotModuleSetSnapshotEngineCommon = require('../../common/SnapshotModuleCommon/SnapshotModuleSetSnapshotEngineCommon')
describe('CMTAT DebtEngine - Standalone Snapshot', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATDebtEngineStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    // this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
    this.erc1404 = true
    this.dontCheckTimestamp = true
    this.transferEngineMock = await ethers.deployContract(
      'SnapshotEngineMock',
      [this.cmtat.target, this.admin]
    )
  })
  VersionModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()
  // Extensions
  ERC20EnforcementModuleCommon()
  ExtraInfoModuleCommon()
  DocumentModuleCommon()
  // Snapshot
  SnapshotModuleMultiplePlannedTest()
  SnapshotModuleOnePlannedSnapshotTest()
  SnapshotModuleZeroPlannedSnapshotTest()
  SnapshotModuleCommonRescheduling()
  SnapshotModuleCommonScheduling()
  SnapshotModuleCommonUnschedule()
  SnapshotModuleCommonGetNextSnapshot()
  // Set snapshot Engine
  SnapshotModuleSetSnapshotEngineCommon
  // options
  DebtEngineModuleCommon()
  DebtModuleSetDebtEngineCommon()
})
