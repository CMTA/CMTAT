const FixDescriptorModuleCommon = require('../../../common/FixDescriptorModule/FixDescriptorModuleCommon')
const {
  deployCMTATStandaloneWithParameter,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe('Standard - FixDescriptorModule - Constructor', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.fixDescriptorEngineMock = await ethers.deployContract(
      'FixDescriptorEngineMock',
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
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, this.fixDescriptorEngineMock.target]
    )
  })
  FixDescriptorModuleCommon()
})
