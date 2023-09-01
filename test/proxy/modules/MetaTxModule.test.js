const { time } = require('@openzeppelin/test-helpers')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_PROXY')
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock')
const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const { deployCMTATProxyWithParameter } = require('../../deploymentUtils')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils')

contract(
  'Proxy - MetaTxModule',
  function ([_, admin, address1, deployerAddress]) {
    beforeEach(async function () {
      this.flag = 5
      const DECIMAL = 0
      this.forwarder = await MinimalForwarderMock.new()
      await this.forwarder.initialize(ERC2771ForwarderDomain)
      const delayTime = BigInt(time.duration.days(3))
      this.cmtat = await deployCMTATProxyWithParameter(
        deployerAddress,
        this.forwarder.address,
        admin,
        delayTime,
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

    MetaTxModuleCommon(admin, address1)
  }
)
