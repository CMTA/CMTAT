const SnapshotModuleCommonRescheduling = require('../../../common/SnapshotModuleCommon/SnapshotModuleCommonRescheduling')
const SnapshotModuleCommonScheduling = require('../../../common/SnapshotModuleCommon/SnapshotModuleCommonScheduling')
const SnapshotModuleCommonUnschedule = require('../../../common/SnapshotModuleCommon/SnapshotModuleCommonUnschedule')
const SnapshotModuleCommonGetNextSnapshot = require('../../../common/SnapshotModuleCommon/SnapshotModuleCommonGetNextSnapshot')
const SnapshotModuleMultiplePlannedTest = require('../../../common/SnapshotModuleCommon/global/SnapshotModuleMultiplePlannedTest')
const SnapshotModuleOnePlannedSnapshotTest = require('../../../common/SnapshotModuleCommon/global/SnapshotModuleOnePlannedSnapshotTest')
const SnapshotModuleZeroPlannedSnapshotTest = require('../../../common/SnapshotModuleCommon/global/SnapshotModuleZeroPlannedSnapshot')

const {
  deployCMTATStandaloneWithParameter,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe('Standard - SnapshotModule - Constructor', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.transferEngineMock = await ethers.deployContract(
      'SnapshotEngineMock',
      [ZERO_ADDRESS, this.admin]
    )
    this.definedAtDeployment = true
    this.cmtat = await deployCMTATStandaloneWithParameter(
      this.deployerAddress.address,
      this._.address,
      this.admin.address,
      'CMTA Token',
      'CMTAT',
      DEPLOYMENT_DECIMAL,
      'CMTAT_ISIN',
      TERMS,
      'CMTAT_info',
      [ZERO_ADDRESS, ZERO_ADDRESS, this.transferEngineMock.target, ZERO_ADDRESS]
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
})
