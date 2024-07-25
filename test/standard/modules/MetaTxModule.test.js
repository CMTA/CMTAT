const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon.js')
const { deployCMTATStandaloneWithParameter, fixture, loadFixture } = require('../../deploymentUtils.js')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils.js')

describe(
  'Standard - MetaTxModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.flag = 50n
      const DECIMAL = 0n

      this.forwarder = await ethers.deployContract("MinimalForwarderMock")
      await this.forwarder.initialize(ERC2771ForwarderDomain)
      this.cmtat = await deployCMTATStandaloneWithParameter(
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
