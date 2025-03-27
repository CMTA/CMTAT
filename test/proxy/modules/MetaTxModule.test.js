const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const {
  deployCMTATProxyWithParameter,
  fixture,
  loadFixture,
  TERMS,
  DEPLOYMENT_DECIMAL
} = require('../../deploymentUtils.js')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils.js')

describe('Proxy - MetaTxModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.flag = 5
    const DECIMAL = 0
    this.forwarder = await ethers.deployContract('MinimalForwarderMock')
    await this.forwarder.initialize(ERC2771ForwarderDomain)
    this.cmtat = await deployCMTATProxyWithParameter(
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
