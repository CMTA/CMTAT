const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const { getUnixTimestamp, timeout, checkArraySnapshot } = require('./SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonGetNextSnapshot (owner, address1, address2, address3) {
  context('Snapshot scheduling', function () {
    it('can get all next snapshots', async function () {
      this.snapshotTime1 = `${getUnixTimestamp() + 100}`
      this.snapshotTime2 = `${getUnixTimestamp() + 600}`
      this.snapshotTime3 = `${getUnixTimestamp() + 1100}`
      this.snapshotTime4 = `${getUnixTimestamp() + 11003}`
      this.snapshotTime5 = `${getUnixTimestamp() + 11004}`
      this.randomSnapshot = `${getUnixTimestamp() + 700}`
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
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(5)
      checkArraySnapshot(snapshots, [this.snapshotTime1, this.snapshotTime2, this.snapshotTime3, this.snapshotTime4, this.snapshotTime5])
    })

    it('return empty array if all snapshots are in the past', async function () {
      this.snapshotTime1 = `${getUnixTimestamp() + 1}`
      this.snapshotTime2 = `${getUnixTimestamp() + 2}`
      this.snapshotTime3 = `${getUnixTimestamp() + 3}`
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime3, {
        from: owner
      })
      await timeout(4000);
      // Update the clock
      ({ logs: this.logs } = await this.cmtat.pause({ from: owner }))
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })

    it('return only future snapshots if some snapshots are in the past', async function () {
      this.snapshotTime1 = `${getUnixTimestamp() + 1}`
      this.snapshotTime2 = `${getUnixTimestamp() + 20}`
      this.snapshotTime3 = `${getUnixTimestamp() + 300}`
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, {
        from: owner
      })
      await timeout(3000)
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime3, {
        from: owner
      })
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(2)
      checkArraySnapshot(snapshots, [this.snapshotTime2, this.snapshotTime3])
      snapshots[0].should.be.bignumber.equal(this.snapshotTime2)
      snapshots[1].should.be.bignumber.equal(this.snapshotTime3)
    })
  })
}
module.exports = SnapshotModuleCommonGetNextSnapshot
