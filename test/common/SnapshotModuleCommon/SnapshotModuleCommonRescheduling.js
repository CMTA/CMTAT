const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const { getUnixTimestamp, checkArraySnapshot } = require('./SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonRescheduling (owner, address1, address2, address3) {
  context('Snapshot rescheduling', function () {
    beforeEach(async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`
      this.newSnapshotTime = `${getUnixTimestamp() + 200}`
      await this.cmtat.scheduleSnapshot(this.snapshotTime, { from: owner })
    })
    
    it('can reschedule a snapshot with the snapshoter role and emits a SnapshotSchedule event', async function () {
      ({ logs: this.logs } = await this.cmtat.rescheduleSnapshot(
        this.snapshotTime,
        this.newSnapshotTime,
        { from: owner }
      ))
      expectEvent.inLogs(this.logs, 'SnapshotSchedule', {
        oldTime: this.snapshotTime,
        newTime: this.newSnapshotTime
      })
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(this.newSnapshotTime)
    })

    it('can reschedule a snapshot between a range of snapshot', async function () {
      this.snapshotMiddleOldTime = this.snapshotTime + 30
      this.snapshotMiddleNewTime = this.snapshotTime + 40
      this.snapshotTime1 = this.snapshotTime + 60
      this.snapshotTime2 = this.snapshotTime + 90
      await this.cmtat.scheduleSnapshot(this.snapshotMiddleOldTime, { from: owner })
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, { from: owner })
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, { from: owner });
      ({ logs: this.logs } = await this.cmtat.rescheduleSnapshot(
        this.snapshotMiddleOldTime,
        this.snapshotMiddleNewTime,
        { from: owner }
      ))
      expectEvent.inLogs(this.logs, 'SnapshotSchedule', {
        oldTime: this.snapshotMiddleOldTime,
        newTime: this.snapshotMiddleNewTime
      })
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(4)
      checkArraySnapshot(snapshots, [this.snapshotTime, this.snapshotMiddleNewTime, this.snapshotTime1, this.snapshotTime2])
    })

    it('revert if reschedule a snapshot not in the range of snapshot', async function () {
      this.snapshotMiddleOldTime = this.snapshotTime + 30
      this.snapshotMiddleNewTime = this.snapshotTime + 61
      this.snapshotTime1 = this.snapshotTime + 60
      this.snapshotTime2 = this.snapshotTime + 90
      await this.cmtat.scheduleSnapshot(this.snapshotMiddleOldTime, { from: owner })
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, { from: owner })
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, { from: owner })
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
          this.snapshotMiddleOldTime,
          this.snapshotMiddleNewTime,
          { from: owner }
        ),
        'time has to be less than the next snapshot'
      )
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(4)
      checkArraySnapshot(snapshots, [this.snapshotTime, this.snapshotMiddleOldTime, this.snapshotTime1, this.snapshotTime2])
    })

    it('revert if reschedule a snapshot not in the range of snapshot', async function () {
      this.snapshotMiddleOldTime = this.snapshotTime + 30
      this.snapshotMiddleNewTime = this.snapshotTime - 1
      this.snapshotTime1 = this.snapshotTime + 60
      this.snapshotTime2 = this.snapshotTime + 90
      await this.cmtat.scheduleSnapshot(this.snapshotMiddleOldTime, { from: owner })
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, { from: owner })
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, { from: owner })
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
          this.snapshotMiddleOldTime,
          this.snapshotMiddleNewTime,
          { from: owner }
        ),
        'time has to be greater than the previous snapshot'
      )
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(4)
      checkArraySnapshot(snapshots, [this.snapshotTime, this.snapshotMiddleOldTime, this.snapshotTime1, this.snapshotTime2])
    })
    
    it('reverts when calling from non-owner', async function () {
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
          this.snapshotTime,
          this.newSnapshotTime,
          { from: address1 }
        ),
        'AccessControl: account ' +
                address1.toLowerCase() +
                ' is missing role ' +
                SNAPSHOOTER_ROLE
      )
    })
    
    it('reverts when trying to reschedule a snapshot in the past', async function () {
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
          this.snapshotTime,
                `${getUnixTimestamp() - 60}`,
                { from: owner }
        ),
        'Snapshot scheduled in the past'
      )
    })
    
    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      await this.cmtat.rescheduleSnapshot(
        this.snapshotTime,
        this.newSnapshotTime,
        { from: owner }
      )
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
          this.snapshotTime,
          this.newSnapshotTime,
          { from: owner }
        ),
        'Snapshot not found'
      )
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(this.newSnapshotTime)
    })
    
    it('reverts when snapshot is not found', async function () {
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
                `${getUnixTimestamp() + 90}`,
                this.newSnapshotTime,
                { from: owner }
        ),
        'Snapshot not found'
      )
    })

    it('reverts if no snapshot exits', async function () {
      ({ logs: this.logs } = await this.cmtat.unscheduleLastSnapshot(
        this.snapshotTime,
        { from: owner }
      ))
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
          this.snapshotTime,
          this.newSnapshotTime,
          { from: owner }
        ),
        'no scheduled snapshot'
      )
    })
    
    it('reverts when snapshot has been processed', async function () {
      await expectRevert(
        this.cmtat.rescheduleSnapshot(
                `${getUnixTimestamp() - 60}`,
                this.newSnapshotTime,
                { from: owner }
        ),
        'Snapshot already done'
      )
    })
  })
}
module.exports = SnapshotModuleCommonRescheduling
