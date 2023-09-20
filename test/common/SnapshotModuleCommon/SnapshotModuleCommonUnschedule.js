const {
  expectEvent,
  expectRevert,
  time
} = require('@openzeppelin/test-helpers')
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const {
  getUnixTimestamp,
  checkArraySnapshot
} = require('./SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonUnschedule (owner, address1, address2, address3) {
  context('unscheduleSnapshotNotOptimized', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      this.snapshotTime1 = this.currentTime.add(time.duration.seconds(10))
      this.snapshotTime2 = this.currentTime.add(time.duration.seconds(15))
      this.snapshotTime3 = this.currentTime.add(time.duration.seconds(20))
      this.snapshotTime4 = this.currentTime.add(time.duration.seconds(25))
      this.snapshotTime5 = this.currentTime.add(time.duration.seconds(30))
      this.snapshotTime6 = this.currentTime.add(time.duration.seconds(40))
    })

    it('can remove a snapshot as admin', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      this.logs = await this.cmtat.scheduleSnapshot(SNAPSHOT_TIME, {
        from: owner
      })
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(SNAPSHOT_TIME)
      await this.cmtat.unscheduleSnapshotNotOptimized(SNAPSHOT_TIME, {
        from: owner
      })
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })
    it('can remove a random snapshot with the snapshoter role', async function () {
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
      await this.cmtat.unscheduleSnapshotNotOptimized(this.snapshotTime3, {
        from: owner
      })
      snapshots = await this.cmtat.getNextSnapshots()
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.snapshotTime3,
        this.snapshotTime4
      ])
      snapshots.length.should.equal(4)
    })
    it('Revert if no snapshot', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
      await expectRevertCustomError(
        this.cmtat.unscheduleSnapshotNotOptimized(SNAPSHOT_TIME, {
          from: owner
        }),
        'CMTAT_SnapshotModule_SnapshotNotFound',
        []
      )
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })
    it('can unschedule a snaphot in a random place', async function () {
      const RANDOM_SNAPSHOT = this.currentTime.add(time.duration.seconds(17))
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
      await this.cmtat.scheduleSnapshotNotOptimized(RANDOM_SNAPSHOT, {
        from: owner
      })
      let snapshots = await this.cmtat.getNextSnapshots()
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.RANDOM_SNAPSHOT,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5
      ])
      snapshots.length.should.equal(6)
      await this.cmtat.unscheduleSnapshotNotOptimized(RANDOM_SNAPSHOT, {
        from: owner
      })
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(5)
      snapshots = await this.cmtat.getNextSnapshots()
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5
      ])
    })
    
    it('reverts when calling from non-owner', async function () {
      // Arrange
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      this.logs = await this.cmtat.scheduleSnapshot(SNAPSHOT_TIME, {
        from: owner
      })
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(SNAPSHOT_TIME)
      // Act
      await expectRevertCustomError(
        this.cmtat.unscheduleSnapshotNotOptimized(SNAPSHOT_TIME, { from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, SNAPSHOOTER_ROLE]
      )
      // Assert
      snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
    })

    it('can schedule a snaphot after an unschedule', async function () {
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
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5,
        this.snapshotTime6
      ])
    })
  })
  context('Snapshot unscheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      this.snapshotTime = this.currentTime.add(time.duration.seconds(60))
      await this.cmtat.scheduleSnapshot(this.snapshotTime, { from: owner })
    })

    it('can unschedule a snapshot with the snapshoter role and emits a SnapshotUnschedule event', async function () {
      this.logs = await this.cmtat.unscheduleLastSnapshot(this.snapshotTime, {
        from: owner
      })
      expectEvent(this.logs, 'SnapshotUnschedule', {
        time: this.snapshotTime
      })
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })

    it('reverts when calling from non-owner', async function () {
      await expectRevertCustomError(
        this.cmtat.unscheduleLastSnapshot(this.snapshotTime, {
          from: address1
        }),
        'AccessControlUnauthorizedAccount',
        [address1, SNAPSHOOTER_ROLE]
      )
    })

    it('reverts if no snapshot is scheduled', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(90))
      // Arrange
      // Delete the only snapshot
      this.logs = await this.cmtat.unscheduleLastSnapshot(this.snapshotTime, {
        from: owner
      })
      // Act
      await expectRevertCustomError(
        this.cmtat.unscheduleLastSnapshot(SNAPSHOT_TIME, {
          from: owner
        }),
        'CMTAT_SnapshotModule_NoSnapshotScheduled',
        []
      )
    })

    it('reverts when snapshot is not found', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(90))
      // Act
      await expectRevertCustomError(
        this.cmtat.unscheduleLastSnapshot(SNAPSHOT_TIME, {
          from: owner
        }),
        'CMTAT_SnapshotModule_SnapshotNotFound',
        []
      )
    })

    it('reverts when snapshot has been processed', async function () {
      const SNAPSHOT_TIME = this.currentTime.sub(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.unscheduleLastSnapshot(SNAPSHOT_TIME, {
          from: owner
        }),
        'CMTAT_SnapshotModule_SnapshotAlreadyDone',
        []
      )
    })
  })
}
module.exports = SnapshotModuleCommonUnschedule
