const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const {
  deployCMTATERC1363Proxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils.js')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils.js')
describe('Standard - MetaTxModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.forwarder = await ethers.deployContract('MinimalForwarderMock')
    await this.forwarder.initialize(ERC2771ForwarderDomain)
    this.cmtat = await deployCMTATERC1363Proxy(
      this.forwarder.target,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  MetaTxModuleCommon()
})
