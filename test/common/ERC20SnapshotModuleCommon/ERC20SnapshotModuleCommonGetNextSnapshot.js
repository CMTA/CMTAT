const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const {
  checkArraySnapshot
} = require('./ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')

function ERC20SnapshotModuleCommonGetNextSnapshot () {
  context('Snapshot scheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
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
      this.snapshotTime1 = this.currentTime + time.duration.seconds(3)
      this.snapshotTime2 = this.currentTime + time.duration.seconds(4)
      this.snapshotTime3 = this.currentTime + time.duration.seconds(5)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      // We jump into the future
      await time.increase(4)
      // Act
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      // Assert
      expect(snapshots.length).to.equal(0)
    })

    it('testCanReturnOnlyFutureSnapshotsIfSomeSnapshotsAreInThePast', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime + time.duration.seconds(3)
      this.snapshotTime2 = this.currentTime + time.duration.seconds(20)
      this.snapshotTime3 = this.currentTime + time.duration.seconds(300)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      // We jump into the future
      await time.increase(3)
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
module.exports = ERC20SnapshotModuleCommonGetNextSnapshot
