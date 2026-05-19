const MetaTxMsgDataCommon = require('../../common/MetaTxMsgDataCommon')
const { upgrades } = require('hardhat')
const {
  DEPLOYMENT_DECIMAL,
  TERMS,
  fixture,
  loadFixture
} = require('../../deploymentUtils.js')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils.js')
describe('Standard - MetaTxModule - _msgData (CMTATBaseERC1363)', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.forwarder = await ethers.deployContract('MinimalForwarderMock')
    await this.forwarder.initialize(ERC2771ForwarderDomain)
    const factory = await ethers.getContractFactory(
      'CMTATUpgradeableERC1363MsgDataMock'
    )
    this.cmtat = await upgrades.deployProxy(
      factory,
      [
        this.admin.address,
        ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
        ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
        [ZERO_ADDRESS]
      ],
      {
        initializer: 'initialize',
        constructorArgs: [this.forwarder.target],
        from: this.deployerAddress.address,
        unsafeAllow: ['missing-initializer']
      }
    )
  })

  MetaTxMsgDataCommon()
})
