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

function ERC20SnapshotModuleCommonScheduling (
  admin,
  address1,
  address2,
  address3
) {
  context('Snapshot scheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
    })
    it('can schedule a snapshot with the snapshoter role', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      // Act
      this.logs = await this.cmtat.connect(this.admin).scheduleSnapshot(SNAPSHOT_TIME)
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

    it('reverts when calling from non-admin', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.connect(address1).scheduleSnapshot(SNAPSHOT_TIME),
        'AccessControlUnauthorizedAccount',
        [address1, SNAPSHOOTER_ROLE]
      )
    })

    it('reverts when trying to schedule a snapshot before the last snapshot', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(120))
      // Act
      this.logs = await this.cmtat.connect(admin).scheduleSnapshot(SNAPSHOT_TIME)
      const SNAPSHOT_TIME_INVALID = SNAPSHOT_TIME.sub(
        time.duration.seconds(60)
      )
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).scheduleSnapshot(SNAPSHOT_TIME_INVALID),
        'CMTAT_SnapshotModule_SnapshotTimestampBeforeLastSnapshot',
        [SNAPSHOT_TIME_INVALID, SNAPSHOT_TIME]
      )
    })

    it('reverts when trying to schedule a snapshot in the past', async function () {
      const SNAPSHOT_TIME = this.currentTime.sub(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).scheduleSnapshot(SNAPSHOT_TIME),
        'CMTAT_SnapshotModule_SnapshotScheduledInThePast',
        [SNAPSHOT_TIME, (await time.latest()).add(time.duration.seconds(1))]
      )
    })

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      // Arrange
      await this.cmtat.connect(this.admin).scheduleSnapshot(SNAPSHOT_TIME)
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).scheduleSnapshot(SNAPSHOT_TIME),
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
      this.logs = await this.cmtat.connect(this.admin).scheduleSnapshot(FIRST_SNAPSHOT)
      this.logs = await this.cmtat.connect(this.admin).scheduleSnapshot(SECOND_SNAPSHOT)
      // Act
      // We schedule the snapshot at the first place
      this.snapshotTime = this.currentTime.add(time.duration.seconds(10))
      this.logs = await this.cmtat.connect(this.admin).scheduleSnapshotNotOptimized(
        THIRD_SNAPSHOT
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
      await this.cmtat.connect(this.admin).scheduleSnapshot(FIRST_SNAPSHOT)
      await this.cmtat.connect(this.admin).scheduleSnapshot(SECOND_SNAPSHOT)
      await this.cmtat.connect(this.admin).scheduleSnapshot(THIRD_SNAPSHOT)
      await this.cmtat.connect(this.admin).scheduleSnapshot(FOUR_SNAPSHOT)
      await this.cmtat.connect(this.admin).scheduleSnapshot(FIVE_SNAPSHOT)
      // Act
      await this.cmtat.connect(this.admin).scheduleSnapshotNotOptimized(RANDOM_SNAPSHOT)
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
      this.logs = await this.cmtat.connect(this.admin).scheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)

      // emits a SnapshotSchedule event
      expectEvent(this.logs, 'SnapshotSchedule', {
        oldTime: '0',
        newTime: SNAPSHOT_TIME
      })
    })

    it('reverts when calling from non-admin', async function () {
      const SNAPSHOT_TIME = this.currentTime.add(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.connect(address1).scheduleSnapshotNotOptimized(SNAPSHOT_TIME),
        'AccessControlUnauthorizedAccount',
        [address1, SNAPSHOOTER_ROLE]
      )
    })

    it('reverts when trying to schedule a snapshot in the past', async function () {
      const SNAPSHOT_TIME = this.currentTime.sub(time.duration.seconds(60))
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).scheduleSnapshotNotOptimized(SNAPSHOT_TIME),
        'CMTAT_SnapshotModule_SnapshotScheduledInThePast',
        [SNAPSHOT_TIME, (await time.latest()).add(time.duration.seconds(1))]
      )
    })

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      const FIRST_SNAPSHOT = this.currentTime.add(time.duration.seconds(10))
      const SECOND_SNAPSHOT = this.currentTime.add(time.duration.seconds(100))
      // Arrange
      this.logs = await this.cmtat.connect(this.admin).scheduleSnapshot(FIRST_SNAPSHOT)
      this.logs = await this.cmtat.connect(this.admin).scheduleSnapshot(SECOND_SNAPSHOT)
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).scheduleSnapshotNotOptimized(FIRST_SNAPSHOT),
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
