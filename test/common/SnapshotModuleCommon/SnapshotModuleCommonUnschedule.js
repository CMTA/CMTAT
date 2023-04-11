const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const { getUnixTimestamp, checkArraySnapshot } = require('./SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonUnschedule (owner, address1, address2, address3) {
  context('unscheduleSnapshotNotOptimized', function () {
    it('can remove a snapshot as admin', async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshot(
        this.snapshotTime,
        { from: owner }
      ))
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(this.snapshotTime)
      await this.cmtat.unscheduleSnapshotNotOptimized(this.snapshotTime, { from: owner })
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })
    it('can remove a random snapshot with the snapshoter role', async function () {
      this.snapshotTime1 = `${getUnixTimestamp() + 100}`
      this.snapshotTime2 = `${getUnixTimestamp() + 600}`
      this.snapshotTime3 = `${getUnixTimestamp() + 1100}`
      this.snapshotTime4 = `${getUnixTimestamp() + 11003}`
      this.snapshotTime5 = `${getUnixTimestamp() + 11004}`
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
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(5)
      await this.cmtat.unscheduleSnapshotNotOptimized(this.snapshotTime3, { from: owner })
      snapshots = await this.cmtat.getNextSnapshots()
      checkArraySnapshot(snapshots, [this.snapshotTime1, this.snapshotTime2, this.snapshotTime4, this.snapshotTime5])
      snapshots.length.should.equal(4)
    })
    it('Revert if no snapshot', async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
      await expectRevert(this.cmtat.unscheduleSnapshotNotOptimized(this.snapshotTime, { from: owner }), 'Snapshot not found')
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })
    it('can unschedule a snaphot in a random place', async function () {
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
      await this.cmtat.scheduleSnapshotNotOptimized(this.randomSnapshot, {
        from: owner
      })
      let snapshots = await this.cmtat.getNextSnapshots()
      checkArraySnapshot(snapshots, [this.snapshotTime1, this.snapshotTime2, this.randomSnapshot, this.snapshotTime3, this.snapshotTime4, this.snapshotTime5])
      snapshots.length.should.equal(6)
      await this.cmtat.unscheduleSnapshotNotOptimized(this.randomSnapshot, {
        from: owner
      })
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(5)
      snapshots = await this.cmtat.getNextSnapshots()
      checkArraySnapshot(snapshots, [this.snapshotTime1, this.snapshotTime2, this.snapshotTime3, this.snapshotTime4, this.snapshotTime5])
    })
    it('can schedule a snaphot after an unschedule', async function () {
      this.snapshotTime1 = `${getUnixTimestamp() + 100}`
      this.snapshotTime2 = `${getUnixTimestamp() + 600}`
      this.snapshotTime3 = `${getUnixTimestamp() + 1100}`
      this.snapshotTime4 = `${getUnixTimestamp() + 11003}`
      this.snapshotTime5 = `${getUnixTimestamp() + 11004}`
      this.snapshotTime6 = `${getUnixTimestamp() + 11009}`
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
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(5)
      await this.cmtat.unscheduleSnapshotNotOptimized(this.snapshotTime2, {
        from: owner
      })
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(4)
      await this.cmtat.scheduleSnapshot(this.snapshotTime6, {
        from: owner
      })
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(5)
      checkArraySnapshot(snapshots, [this.snapshotTime1, this.snapshotTime3, this.snapshotTime4, this.snapshotTime5, this.snapshotTime6])
    })
  })
  context('Snapshot unscheduling', function () {
    beforeEach(async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`
      await this.cmtat.scheduleSnapshot(this.snapshotTime, { from: owner })
    })
    it('can unschedule a snapshot with the snapshoter role and emits a SnapshotUnschedule event', async function () {
      ({ logs: this.logs } = await this.cmtat.unscheduleLastSnapshot(
        this.snapshotTime,
        { from: owner }
      ))
      expectEvent.inLogs(this.logs, 'SnapshotUnschedule', {
        time: this.snapshotTime
      })
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })

    it('reverts when calling from non-owner', async function () {
      await expectRevert(
        this.cmtat.unscheduleLastSnapshot(this.snapshotTime, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            SNAPSHOOTER_ROLE
      )
    })

    it('reverts if no snapshot is scheduled', async function () {
      // Delete the only snapshot
      ({ logs: this.logs } = await this.cmtat.unscheduleLastSnapshot(
        this.snapshotTime,
        { from: owner }
      ))
      await expectRevert(
        this.cmtat.unscheduleLastSnapshot(`${getUnixTimestamp() + 90}`, {
          from: owner
        }),
        'No snapshot scheduled'
      )
    })

    it('reverts when snapshot is not found', async function () {
      await expectRevert(
        this.cmtat.unscheduleLastSnapshot(`${getUnixTimestamp() + 90}`, {
          from: owner
        }),
        'Only the last snapshot can be unscheduled'
      )
    })

    it('reverts when snapshot has been processed', async function () {
      await expectRevert(
        this.cmtat.unscheduleLastSnapshot(`${getUnixTimestamp() - 60}`, {
          from: owner
        }),
        'Snapshot already done'
      )
    })
  })
}
module.exports = SnapshotModuleCommonUnschedule
