const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_PROXY')
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock')
const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils')

contract(
  'Proxy - MetaTxModule',
  function ([
    _,
    admin,
    address1
  ]) {
    beforeEach(async function () {
      this.flag = 5
      const DECIMAL = 0
      this.forwarder = await MinimalForwarderMock.new()
      await this.forwarder.initialize(ERC2771ForwarderDomain)
      this.cmtat = await deployProxy(CMTAT, [admin, 'CMTA Token', 'CMTAT', DECIMAL, 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [this.forwarder.address]
      })
    })

    MetaTxModuleCommon(admin, address1)
  }
)
