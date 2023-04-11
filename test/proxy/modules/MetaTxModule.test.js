const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT_PROXY')
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock')
const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const { ZERO_ADDRESS } = require('../../utils')

contract(
  'Proxy - MetaTxModule',
  function ([
    _,
    owner,
    address1
  ]) {
    beforeEach(async function () {
      this.flag = 5
      this.trustedForwarder = await MinimalForwarderMock.new()
      await this.trustedForwarder.initialize()
      this.cmtat = await deployProxy(CMTAT, [owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
        initializer: 'initialize',
        constructorArgs: [this.trustedForwarder.address]
      })
    })

    MetaTxModuleCommon(owner, address1)
  }
)
