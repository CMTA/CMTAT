const MetaTxMsgDataCommon = require('../../common/MetaTxMsgDataCommon')
const {
  DEPLOYMENT_DECIMAL,
  TERMS,
  fixture,
  loadFixture
} = require('../../deploymentUtils.js')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils.js')
describe('Standard - MetaTxModule - _msgData (CMTATBaseERC2771)', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.forwarder = await ethers.deployContract('MinimalForwarderMock')
    await this.forwarder.initialize(ERC2771ForwarderDomain)
    this.cmtat = await ethers.deployContract('CMTATStandaloneMsgDataMock', [
      this.forwarder.target,
      this.admin.address,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
      [ZERO_ADDRESS]
    ])
  })

  MetaTxMsgDataCommon()
})
