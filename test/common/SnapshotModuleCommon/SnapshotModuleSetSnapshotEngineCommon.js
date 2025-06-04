const { expect } = require('chai')
const { SNAPSHOOTER_ROLE, ZERO_ADDRESS } = require('../../utils.js')

function SnapshotModuleSetSnapshotEngineCommon () {
  context('SnapshotEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setSnapshotEngine(this.transferEngineMock.target)
      // Assert
      // emits a SnapshotEngineSet event
      await expect(this.logs)
        .to.emit(this.cmtat, 'SnapshotEngine')
        .withArgs(this.transferEngineMock.target)
    })

    it('testCannotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .setSnapshotEngine(await this.cmtat.snapshotEngine())
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_SnapshotModule_SameValue'
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .setSnapshotEngine(this.transferEngineMock.target)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, SNAPSHOOTER_ROLE)
    })
  })
}
module.exports = SnapshotModuleSetSnapshotEngineCommon
