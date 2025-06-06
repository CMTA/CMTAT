const DocumentModuleCommon = require('../../../common/DocumentModule/DocumentModuleCommon')
const {
  deployCMTATProxyWithParameter,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe('Proxy - DocumentModule - Constructor', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.documentEngineMock = await ethers.deployContract('DocumentEngineMock')
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
      [ZERO_ADDRESS, ZERO_ADDRESS, this.documentEngineMock.target]
    )
  })
  DocumentModuleCommon()
})
