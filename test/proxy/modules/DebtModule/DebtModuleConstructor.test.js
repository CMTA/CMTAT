const DebtModuleCommon = require('../../../common/DebtModule/DebtModuleCommon')
const {
  deployCMTATProxyWithParameter,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe('Proxy - DebtModule - Constructor', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    const DECIMAL = 0
    this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
    this.definedAtDeployment = true
    this.cmtat = await deployCMTATProxyWithParameter(
      this.deployerAddress.address,
      this._.address,
      this.admin.address,
      'CMTA Token',
      'CMTAT',
      DEPLOYMENT_DECIMAL,
      'CMTAT_ISIN',
      TERMS,
      'CMTAT_info',
      [ZERO_ADDRESS, this.debtEngineMock.target, ZERO_ADDRESS]
    )
  })
  DebtModuleCommon()
})
