const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { ZERO_ADDRESS } = require('../../utils')
const {
  checkArraySnapshot
} = require('./SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonGetNextSnapshot () {
  context('Snapshot scheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      if ((await this.cmtat.snapshotEngine()) === ZERO_ADDRESS) {
        this.transferEngineMock = await ethers.deployContract(
          'SnapshotEngineMock',
          [this.cmtat.target, this.admin]
        )
        await this.cmtat
          .connect(this.admin)
          .setSnapshotEngine(this.transferEngineMock)
      }
    })
    it('testCanReturnTheRightAddressIfSet', async function () {
      // Only meaningful when the snapshot engine is wired at deployment
      if (!this.definedAtDeployment) {
        this.skip()
      }
      const transferEngine = await this.cmtat.snapshotEngine()
      expect(this.transferEngineMock.target).to.equal(transferEngine)
    })
    it('testCanGetAllNextSnapshots', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime + time.duration.seconds(10)
      this.snapshotTime2 = this.currentTime + time.duration.seconds(15)
      this.snapshotTime3 = this.currentTime + time.duration.seconds(20)
      this.snapshotTime4 = this.currentTime + time.duration.seconds(25)
      this.snapshotTime5 = this.currentTime + time.duration.seconds(30)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime4)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime5)
      // Act
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      // Assert
      expect(snapshots.length).to.equal(5)
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5
      ])
      // Act
      const AllSnapshots = await this.transferEngineMock.getAllSnapshots()
      // Assert
      checkArraySnapshot(AllSnapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5
      ])
    })

    //
    it('testCanReturnEmptyArrayIfAllSnapshotsAreInThePast', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime + time.duration.seconds(4)
      this.snapshotTime2 = this.currentTime + time.duration.seconds(5)
      this.snapshotTime3 = this.currentTime + time.duration.seconds(6)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      // Jump deterministically past the latest snapshot (avoids relying on the
      // 1s-per-tx auto-mine drift to push the snapshots into the past)
      await time.increaseTo(this.snapshotTime3 + 1)
      // Act
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      // Assert
      expect(snapshots.length).to.equal(0)
    })

    it('testCanReturnOnlyFutureSnapshotsIfSomeSnapshotsAreInThePast', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime + time.duration.seconds(4)
      this.snapshotTime2 = this.currentTime + time.duration.seconds(20)
      this.snapshotTime3 = this.currentTime + time.duration.seconds(300)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      // Jump deterministically just past snapshotTime1 (but before snapshotTime2)
      await time.increaseTo(this.snapshotTime1 + 1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      // Act
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      // Assert
      expect(snapshots.length).to.equal(2)
      checkArraySnapshot(snapshots, [this.snapshotTime2, this.snapshotTime3])
      expect(snapshots[0]).to.equal(this.snapshotTime2)
      expect(snapshots[1]).to.equal(this.snapshotTime3)
    })
  })
}
module.exports = SnapshotModuleCommonGetNextSnapshot
