const { time } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { checkArraySnapshot } = require('./SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonGetNextSnapshot (owner, address1, address2, address3) {
  context('Snapshot scheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
    })
    it('can get all next snapshots', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime.add(time.duration.seconds(10))
      this.snapshotTime2 = this.currentTime.add(time.duration.seconds(15))
      this.snapshotTime3 = this.currentTime.add(time.duration.seconds(20))
      this.snapshotTime4 = this.currentTime.add(time.duration.seconds(25))
      this.snapshotTime5 = this.currentTime.add(time.duration.seconds(30))
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime3, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime4, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime5, {
        from: owner
      })
      // Act
      const snapshots = await this.cmtat.getNextSnapshots()
      // Assert
      snapshots.length.should.equal(5)
      checkArraySnapshot(snapshots, [this.snapshotTime1, this.snapshotTime2, this.snapshotTime3, this.snapshotTime4, this.snapshotTime5])
    })

    it('return empty array if all snapshots are in the past', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime.add(time.duration.seconds(2))
      this.snapshotTime2 = this.currentTime.add(time.duration.seconds(3))
      this.snapshotTime3 = this.currentTime.add(time.duration.seconds(4))
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime3, {
        from: owner
      })
      // We jump into the future
      await time.increase(4)
      // Act
      const snapshots = await this.cmtat.getNextSnapshots()
      // Assert
      snapshots.length.should.equal(0)
    })

    it('return only future snapshots if some snapshots are in the past', async function () {
      // Arrange
      this.snapshotTime1 = this.currentTime.add(time.duration.seconds(2))
      this.snapshotTime2 = this.currentTime.add(time.duration.seconds(20))
      this.snapshotTime3 = this.currentTime.add(time.duration.seconds(300))
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, {
        from: owner
      })
      // We jump into the future
      await time.increase(3)
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime3, {
        from: owner
      })
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
module.exports = SnapshotModuleCommonGetNextSnapshot
