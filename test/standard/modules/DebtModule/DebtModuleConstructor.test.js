const DebtModuleCommon = require('../../../common/DebtModule/DebtModuleCommon')
const {
  deployCMTATStandaloneWithParameter,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe('Standard - DebtModule - Constructor', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    const DECIMAL = 0
    this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
    this.definedAtDeployment = true
    this.cmtat = await deployCMTATStandaloneWithParameter(
      this.deployerAddress.address,
      this._.address,
      this.admin.address,
      'CMTA Token',
      'CMTAT',
      DECIMAL,
      'CMTAT_ISIN',
      'https://cmta.ch',
      'CMTAT_info',
      [ZERO_ADDRESS, this.debtEngineMock.target, ZERO_ADDRESS, ZERO_ADDRESS]
    )
  })
  DebtModuleCommon()
})
