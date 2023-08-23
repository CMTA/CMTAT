const CMTAT = artifacts.require('CMTAT_STANDALONE')
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock')
const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const { deployCMTATStandaloneWithParameter } = require('../../deploymentUtils')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils')

contract(
  'Standard - MetaTxModule',
  function ([_, admin, address1, deployerAddress]) {
    beforeEach(async function () {
      this.flag = 5
      const DECIMAL = 0
      this.forwarder = await MinimalForwarderMock.new()
      await this.forwarder.initialize(ERC2771ForwarderDomain)
      this.cmtat = await deployCMTATStandaloneWithParameter(
        deployerAddress,
        this.forwarder.address,
        admin,
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
