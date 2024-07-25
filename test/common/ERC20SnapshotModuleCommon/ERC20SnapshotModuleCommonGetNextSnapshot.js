const { time } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
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
      this.snapshotTime1 = this.currentTime.add(time.duration.seconds(10))
      this.snapshotTime2 = this.currentTime.add(time.duration.seconds(15))
      this.snapshotTime3 = this.currentTime.add(time.duration.seconds(20))
      this.snapshotTime4 = this.currentTime.add(time.duration.seconds(25))
      this.snapshotTime5 = this.currentTime.add(time.duration.seconds(30))
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime1)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime2)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime3)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime4)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime5)
      // Act
      const snapshots = await this.cmtat.getNextSnapshots()
      // Assert
      snapshots.length.should.equal(5)
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5
      ])
      // Act
      const AllSnapshots = await this.cmtat.getAllSnapshots()
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
      this.snapshotTime1 = this.currentTime.add(time.duration.seconds(2))
      this.snapshotTime2 = this.currentTime.add(time.duration.seconds(3))
      this.snapshotTime3 = this.currentTime.add(time.duration.seconds(4))
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime1)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime2)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime3)
      // We jump into the future
      await time.increase(4)
      // Act
      const snapshots = await this.cmtat.getNextSnapshots()
      // Assert
      snapshots.length.should.equal(0)
    })

    it('testCanReturnOnlyFutureSnapshotsIfSomeSnapshotsAreInThePast', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime.add(time.duration.seconds(2))
      this.snapshotTime2 = this.currentTime.add(time.duration.seconds(20))
      this.snapshotTime3 = this.currentTime.add(time.duration.seconds(300))
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime1)
      // We jump into the future
      await time.increase(3)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime2)
      await this.cmtat.connect(this.admin).scheduleSnapshot(this.snapshotTime3)
      // Act
      const snapshots = await this.cmtat.getNextSnapshots()
      // Assert
      snapshots.length.should.equal(2)
      checkArraySnapshot(snapshots, [this.snapshotTime2, this.snapshotTime3])
      snapshots[0].should.be.bignumber.equal(this.snapshotTime2)
      snapshots[1].should.be.bignumber.equal(this.snapshotTime3)
    })
  })
}
module.exports = ERC20SnapshotModuleCommonGetNextSnapshot
