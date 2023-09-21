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
  checkArraySnapshot
} = require('./ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')

function ERC20SnapshotModuleCommonScheduling (owner, address1, address2, address3) {
  context('Snapshot scheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
    })
    it('can schedule a snapshot with the snapshoter role', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      // Act
      this.logs = await this.cmtat.scheduleSnapshot(SNAPSHOT_TIME, {
        from: owner
      })
      // Assert
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(SNAPSHOT_TIME)

      // emits a SnapshotSchedule event
      expectEvent(this.logs, 'SnapshotSchedule', {
        oldTime: '0',
        newTime: SNAPSHOT_TIME
      })
    })

    it('reverts when calling from non-owner', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.scheduleSnapshot(SNAPSHOT_TIME, { from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, SNAPSHOOTER_ROLE]
      )
    })

    it('reverts when trying to schedule a snapshot in the past', async function () {
      const SNAPSHOT_TIME = this.currentTime.sub(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.scheduleSnapshot(SNAPSHOT_TIME, {
          from: owner
        }),
        'CMTAT_SnapshotModule_SnapshotScheduledInThePast',
        [SNAPSHOT_TIME, (await time.latest()).add(time.duration.seconds(1))]
      )
    })

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      // Arrange
      await this.cmtat.scheduleSnapshot(SNAPSHOT_TIME, { from: owner })
      // Act
      await expectRevertCustomError(
        this.cmtat.scheduleSnapshot(SNAPSHOT_TIME, { from: owner }),
        'CMTAT_SnapshotModule_SnapshotAlreadyExists',
        []
      )
      // Assert
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
      snapshots[0].should.be.bignumber.equal(SNAPSHOT_TIME)
    })
  })

  context('Snapshot scheduling NotOptimized', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
    })
    it('can schedule a snapshot in the first place with the snapshoter role', async function () {
      const FIRST_SNAPSHOT = this.currentTime.add(time.duration.seconds(100))
      const SECOND_SNAPSHOT = this.currentTime.add(time.duration.seconds(200))
      const THIRD_SNAPSHOT = this.currentTime.add(time.duration.seconds(15))
      // Arrange
      this.logs = await this.cmtat.scheduleSnapshot(FIRST_SNAPSHOT, {
        from: owner
      })
      this.logs = await this.cmtat.scheduleSnapshot(SECOND_SNAPSHOT, {
        from: owner
      })
      // Act
      // We schedule the snapshot at the first place
      this.snapshotTime = this.currentTime.add(time.duration.seconds(10))
      this.logs = await this.cmtat.scheduleSnapshotNotOptimized(
        THIRD_SNAPSHOT,
        {
          from: owner
        }
      )
      // Assert
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(3)
      snapshots[0].should.be.bignumber.equal(THIRD_SNAPSHOT)
    })

    it('can schedule a snaphot in a random place', async function () {
      // Arrange
      const FIRST_SNAPSHOT = this.currentTime.add(time.duration.seconds(10))
      const SECOND_SNAPSHOT = this.currentTime.add(time.duration.seconds(15))
      const THIRD_SNAPSHOT = this.currentTime.add(time.duration.seconds(20))
      const FOUR_SNAPSHOT = this.currentTime.add(time.duration.seconds(25))
      const FIVE_SNAPSHOT = this.currentTime.add(time.duration.seconds(30))
      // Third position
      const RANDOM_SNAPSHOT = this.currentTime.add(time.duration.seconds(17))
      await this.cmtat.scheduleSnapshot(FIRST_SNAPSHOT, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(SECOND_SNAPSHOT, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(THIRD_SNAPSHOT, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(FOUR_SNAPSHOT, {
        from: owner
      })
      await this.cmtat.scheduleSnapshot(FIVE_SNAPSHOT, {
        from: owner
      })
      // Act
      await this.cmtat.scheduleSnapshotNotOptimized(RANDOM_SNAPSHOT, {
        from: owner
      })
      // Assert
      let snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(6)
      snapshots = await this.cmtat.getNextSnapshots()
      checkArraySnapshot(snapshots, [
        FIRST_SNAPSHOT,
        SECOND_SNAPSHOT,
        RANDOM_SNAPSHOT,
        THIRD_SNAPSHOT,
        FOUR_SNAPSHOT,
        FIVE_SNAPSHOT
      ])
    })

    it('schedule a snapshot, which will be in the last position', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      this.logs = await this.cmtat.scheduleSnapshotNotOptimized(SNAPSHOT_TIME, {
        from: owner
      })
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)

      // emits a SnapshotSchedule event
      expectEvent(this.logs, 'SnapshotSchedule', {
        oldTime: '0',
        newTime: SNAPSHOT_TIME
      })
    })

    it('reverts when calling from non-owner', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.scheduleSnapshotNotOptimized(SNAPSHOT_TIME, {
          from: address1
        }),
        'AccessControlUnauthorizedAccount',
        [address1, SNAPSHOOTER_ROLE]
      )
    })

    it('reverts when trying to schedule a snapshot in the past', async function () {
      const SNAPSHOT_TIME = this.currentTime.sub(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.scheduleSnapshotNotOptimized(SNAPSHOT_TIME, {
          from: owner
        }),
        'CMTAT_SnapshotModule_SnapshotScheduledInThePast',
        [SNAPSHOT_TIME, (await time.latest()).add(time.duration.seconds(1))]
      )
    })

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      const FIRST_SNAPSHOT = this.currentTime.add(time.duration.seconds(10))
      const SECOND_SNAPSHOT = this.currentTime.add(time.duration.seconds(100))
      // Arrange
      this.logs = await this.cmtat.scheduleSnapshot(FIRST_SNAPSHOT, {
        from: owner
      })
      this.logs = await this.cmtat.scheduleSnapshot(SECOND_SNAPSHOT, {
        from: owner
      })
      // Act
      await expectRevertCustomError(
        this.cmtat.scheduleSnapshotNotOptimized(FIRST_SNAPSHOT, {
          from: owner
        }),
        'CMTAT_SnapshotModule_SnapshotAlreadyExists',
        []
      )
      // Assert
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(2)
      checkArraySnapshot(snapshots, [FIRST_SNAPSHOT, SECOND_SNAPSHOT])
    })
  })
}
module.exports = ERC20SnapshotModuleCommonScheduling
