const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon.js')
const { deployCMTATProxyWithParameter, fixture, loadFixture } = require('../../deploymentUtils')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils')

describe(
  'Proxy - MetaTxModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.flag = 5
      const DECIMAL = 0
      this.forwarder = await ethers.deployContract("MinimalForwarderMock")
      await this.forwarder.initialize(ERC2771ForwarderDomain)
      this.cmtat = await deployCMTATProxyWithParameter(
        this.deployerAddress,
        this.forwarder,
        this.admin,
        ZERO_ADDRESS,
        'CMTA Token',
        'CMTAT',
        DECIMAL,
        'CMTAT_ISIN',
        'https://cmta.ch',
        ZERO_ADDRESS,
        'CMTAT_info',
        this.flag
      )
    })

    MetaTxModuleCommon()
  }
)
