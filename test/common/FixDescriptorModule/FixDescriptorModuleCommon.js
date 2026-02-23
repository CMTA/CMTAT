const { expect } = require('chai')
const { ZERO_ADDRESS } = require('../../utils')

function FixDescriptorModuleCommon () {
  context('FixDescriptor Module Test', function () {
    beforeEach(async function () {
      if (!this.definedAtDeployment) {
        this.fixDescriptorEngineMock = await ethers.deployContract(
          'FixDescriptorEngineMock',
          [this.cmtat.target, this.admin]
        )
      }
      if ((await this.cmtat.fixDescriptorEngine()) === ZERO_ADDRESS) {
        await this.cmtat
          .connect(this.admin)
          .setFixDescriptorEngine(this.fixDescriptorEngineMock.target)
      }
    })
    it('testCanReturnTheRightAddressIfSet', async function () {
      const fixDescriptorEngine = await this.cmtat.fixDescriptorEngine()
      expect(this.fixDescriptorEngineMock.target).to.equal(fixDescriptorEngine)
    })
    it('testCanSetZeroAddressEngine', async function () {
      await this.cmtat
        .connect(this.admin)
        .setFixDescriptorEngine(ZERO_ADDRESS)

      expect(await this.cmtat.fixDescriptorEngine()).to.equal(ZERO_ADDRESS)
    })
  })
}
module.exports = FixDescriptorModuleCommon
