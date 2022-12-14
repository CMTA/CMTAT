const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock')
const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')

contract(
  'Proxy - MetaTxModule',
  function ([
    _,
    owner,
    address1
  ]) {
    beforeEach(async function () {
      this.trustedForwarder = await MinimalForwarderMock.new()
      await this.trustedForwarder.initialize()
      this.cmtat = await deployProxy(CMTAT, [true, owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], {
        initializer: 'initialize',
        constructorArgs: [this.trustedForwarder.address, true, owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch']
      })
    })

    MetaTxModuleCommon(owner, address1)
  }
)
