const DocumentModuleCommon = require('../../../common/DocumentModule/DocumentModuleCommon')
const {
  deployCMTATProxyWithParameter,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe('Standard - DocumentModule - Constructor', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    const DECIMAL = 0
    this.documentEngineMock = await ethers.deployContract('DocumentEngineMock')
    this.definedAtDeployment = true
    this.cmtat = await deployCMTATProxyWithParameter(
      this.deployerAddress.address,
      this._.address,
      this.admin.address,
      'CMTA Token',
      'CMTAT',
      DECIMAL,
      'CMTAT_ISIN',
      'https://cmta.ch',
      'CMTAT_info',
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, this.documentEngineMock.target]
    )
  })
  DocumentModuleCommon()
})
