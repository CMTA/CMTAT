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

function SnapshotModuleCommonScheduling (owner, address1, address2, address3) {
  context('Snapshot scheduling', function () {
    it('can schedule a snapshot with the snapshoter role', async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshot(
        this.snapshotTime,
        { from: owner }
      ))
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(this.snapshotTime)
    })
        
    it('emits a SnapshotSchedule event', function () {
      expectEvent.inLogs(this.logs, 'SnapshotSchedule', {
        oldTime: '0',
        newTime: this.snapshotTime
      })
    })
        
    it('reverts when calling from non-owner', async function () {
      await expectRevert(
        this.cmtat.scheduleSnapshot(this.snapshotTime, { from: address1 }),
        'AccessControl: account ' +
                    address1.toLowerCase() +
                    ' is missing role ' +
                    SNAPSHOOTER_ROLE
      )
    })
        
    it('reverts when trying to schedule a snapshot in the past', async function () {
      await expectRevert(
        this.cmtat.scheduleSnapshot(`${getUnixTimestamp() - 60}`, {
          from: owner
        }),
        'Snapshot scheduled in the past'
      )
    })      
    
    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      await this.cmtat.scheduleSnapshot(this.snapshotTime, { from: owner })
      await expectRevert(
        this.cmtat.scheduleSnapshot(this.snapshotTime, { from: owner }),
        'time has to be greater than the last snapshot time'
      )
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(this.snapshotTime)
    })
  })

  context('Snapshot scheduling NotOptimized', function () {
    it('can schedule a snapshot with the snapshoter role', async function () {
      this.snapshotTime = `${getUnixTimestamp() + 600}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshot(
        this.snapshotTime,
        { from: owner }
      ))
      this.snapshotTime = `${getUnixTimestamp() + 1000}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshot(
        this.snapshotTime,
        { from: owner }
      ))
      this.snapshotTime = `${getUnixTimestamp() + 100}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshotNotOptimized(this.snapshotTime, {
        from: owner
      }))
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(3)
      snapshots[0].should.be.bignumber.equal(this.snapshotTime)
    })
        
    it('emits a SnapshotSchedule event', function () {
      expectEvent.inLogs(this.logs, 'SnapshotSchedule', {
        oldTime: '0',
        newTime: this.snapshotTime
      })
    })
    it('schedule a snapshot, which will be in the last position', async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`;
      ({ logs: this.logs } =
        await this.cmtat.scheduleSnapshotNotOptimized(this.snapshotTime, {
          from: owner
        }))
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
    })
        
    it('emits a SnapshotSchedule event', function () {
      expectEvent.inLogs(this.logs, 'SnapshotSchedule', {
        oldTime: '0',
        newTime: this.snapshotTime
      })
    })
        
    it('reverts when calling from non-owner', async function () {
      await expectRevert(
        this.cmtat.scheduleSnapshotNotOptimized(this.snapshotTime, { from: address1 }),
        'AccessControl: account ' +
                    address1.toLowerCase() +
                    ' is missing role ' +
                    SNAPSHOOTER_ROLE
      )
    })
        
    it('reverts when trying to schedule a snapshot in the past', async function () {
      await expectRevert(
        this.cmtat.scheduleSnapshotNotOptimized(`${getUnixTimestamp() - 60}`, {
          from: owner
        }),
        'Snapshot scheduled in the past'
      )
    })      
    
    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      this.firstSnapshotTime = `${getUnixTimestamp() + 400}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshot(
        this.firstSnapshotTime,
        { from: owner }
      ))
      this.snapshotTime = `${getUnixTimestamp() + 600}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshot(
        this.snapshotTime,
        { from: owner }
      ))

      await expectRevert(
        this.cmtat.scheduleSnapshotNotOptimized(this.firstSnapshotTime, { from: owner }),
        'Snapshot already exists'
      )
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(2)
      snapshots[0].should.be.bignumber.equal(this.firstSnapshotTime)
      snapshots[1].should.be.bignumber.equal(this.snapshotTime)
    })
  })
}
module.exports = SnapshotModuleCommonScheduling