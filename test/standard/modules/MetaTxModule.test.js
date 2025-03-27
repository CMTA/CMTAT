const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const {
  deployCMTATStandaloneWithParameter,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../../deploymentUtils.js')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils.js')
describe('Standard - MetaTxModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.forwarder = await ethers.deployContract('MinimalForwarderMock')
    await this.forwarder.initialize(ERC2771ForwarderDomain)
    this.cmtat = await deployCMTATStandaloneWithParameter(
      this.deployerAddress.address,
      this.forwarder.target,
      this.admin.address,
      'CMTA Token',
      'CMTAT',
      DEPLOYMENT_DECIMAL,
      'CMTAT_ISIN',
      TERMS,
      'CMTAT_info',
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
    )
  })

  MetaTxModuleCommon()
})
