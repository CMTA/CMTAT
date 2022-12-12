const CMTAT = artifacts.require('CMTAT')
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock')
const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')

contract(
  'Standard - MetaTxModule',
  function ([
    _,
    admin,
    address1
  ]) {
    beforeEach(async function () {
      this.trustedForwarder = await MinimalForwarderMock.new()
      this.trustedForwarder.initialize()
      this.cmtat = await CMTAT.new(this.trustedForwarder.address, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', { from: admin })
    })

    MetaTxModuleCommon(admin, address1)
  }
)
