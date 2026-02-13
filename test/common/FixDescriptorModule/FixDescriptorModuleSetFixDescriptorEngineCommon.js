const { expect } = require('chai')
const { DESCRIPTOR_ENGINE_ROLE, ZERO_ADDRESS } = require('../../utils.js')

function FixDescriptorModuleSetFixDescriptorEngineCommon () {
  context('FixDescriptorEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      this.fixDescriptorEngineMock = await ethers.deployContract(
        'FixDescriptorEngineMock',
        [ZERO_ADDRESS, this.admin]
      )
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setFixDescriptorEngine(this.fixDescriptorEngineMock.target)
      // Assert
      // emits a FixDescriptorEngineSet event
      await expect(this.logs)
        .to.emit(this.cmtat, 'FixDescriptorEngine')
        .withArgs(this.fixDescriptorEngineMock.target)
    })

    it('testCannotBeSetByAdminWithTheSameValue', async function () {
      const fixDescriptorEngineCurrent = await this.cmtat.fixDescriptorEngine()
      // Act
      await expect(
        this.cmtat.connect(this.admin).setFixDescriptorEngine(fixDescriptorEngineCurrent)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_FixDescriptorModule_SameValue'
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      this.fixDescriptorEngineMock = await ethers.deployContract(
        'FixDescriptorEngineMock',
        [ZERO_ADDRESS, this.admin]
      )
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .setFixDescriptorEngine(this.fixDescriptorEngineMock.target)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DESCRIPTOR_ENGINE_ROLE)
    })
  })
}
module.exports = FixDescriptorModuleSetFixDescriptorEngineCommon
