const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const CMTAT = artifacts.require('CMTAT')

const getUnixTimestamp = () => {
  return Math.round(new Date().getTime() / 1000)
}

const timeout = function (ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function SnapshotModuleCommonRescheduling (owner, address1, address2, address3) {
  context('Snapshot rescheduling', function () {
    beforeEach(async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`
      this.newSnapshotTime = `${getUnixTimestamp() + 90}`
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
