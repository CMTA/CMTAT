const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const {
  deployCMTATAllowlistStandalone,
  fixture,
  loadFixture
} = require('../../deploymentUtils.js')
const { ERC2771ForwarderDomain } = require('../../utils.js')
describe('Standard - MetaTxModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.forwarder = await ethers.deployContract('MinimalForwarderMock')
    await this.forwarder.initialize(ERC2771ForwarderDomain)
    this.cmtat = await deployCMTATAllowlistStandalone(
      this.forwarder.target,
      this.admin.address,
      this.deployerAddress.address
    )
    const accounts = [this.address1, this.address2, this.address3, this.admin]
    const Allowlist = [true, true, true, true]
    await this.cmtat
      .connect(this.admin)
      .batchSetAddressAllowlist(accounts, Allowlist)
  })

  MetaTxModuleCommon()
})
