const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const {
  checkArraySnapshot
} = require('./ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')

function ERC20SnapshotModuleCommonRescheduling () {
  context('Snapshot rescheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      this.snapshotTime = this.currentTime + time.duration.seconds(60)
      this.newSnapshotTime = this.currentTime + time.duration.seconds(200)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime)
    })

    it('can reschedule a snapshot with the snapshoter role and emits a SnapshotSchedule event', async function () {
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime)
      await expect(this.logs)
        .to.emit(this.transferEngineMock, 'SnapshotSchedule')
        .withArgs(this.snapshotTime, this.newSnapshotTime)
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
      expect(snapshots[0]).to.equal(this.newSnapshotTime)
    })

    it('can reschedule a snapshot between a range of snapshot', async function () {
      const SNAPSHOT_MIDDLE_OLD_TIME =
        this.snapshotTime + time.duration.seconds(30)
      const SNAPSHOT_MIDDLE_NEW_TIME =
        this.snapshotTime + time.duration.seconds(40)
      const FIRST_SNAPSHOT = this.snapshotTime + time.duration.seconds(60)
      const SECOND_SNAPSHOT = this.snapshotTime + time.duration.seconds(90)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_MIDDLE_OLD_TIME)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FIRST_SNAPSHOT)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SECOND_SNAPSHOT)
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .rescheduleSnapshot(SNAPSHOT_MIDDLE_OLD_TIME, SNAPSHOT_MIDDLE_NEW_TIME)
      await expect(this.logs)
        .to.emit(this.transferEngineMock, 'SnapshotSchedule')
        .withArgs(SNAPSHOT_MIDDLE_OLD_TIME, SNAPSHOT_MIDDLE_NEW_TIME)
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(4)
      checkArraySnapshot(snapshots, [
        this.snapshotTime,
        SNAPSHOT_MIDDLE_NEW_TIME,
        FIRST_SNAPSHOT,
        SECOND_SNAPSHOT
      ])
    })

    it('testCannotRescheduleASnapshotAfterTheNextSnapshot', async function () {
      const SNAPSHOT_MIDDLE_OLD_TIME =
        this.snapshotTime + time.duration.seconds(30)
      const SNAPSHOT_MIDDLE_NEW_TIME =
        this.snapshotTime + time.duration.seconds(61)
      const FIRST_SNAPSHOT = this.snapshotTime + time.duration.seconds(60)
      const SECOND_SNAPSHOT = this.snapshotTime + time.duration.seconds(90)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_MIDDLE_OLD_TIME)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FIRST_SNAPSHOT)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SECOND_SNAPSHOT)
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(
            SNAPSHOT_MIDDLE_OLD_TIME,
            SNAPSHOT_MIDDLE_NEW_TIME
          )
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'CMTAT_SnapshotModule_SnapshotTimestampAfterNextSnapshot'
        )
        .withArgs(SNAPSHOT_MIDDLE_NEW_TIME, FIRST_SNAPSHOT)
      // Assert
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(4)
      checkArraySnapshot(snapshots, [
        this.snapshotTime,
        SNAPSHOT_MIDDLE_OLD_TIME,
        FIRST_SNAPSHOT,
        SECOND_SNAPSHOT
      ])
    })

    it('testCannotRescheduleASnapshotBeforeThePreviousSnapshot', async function () {
      const SNAPSHOT_MIDDLE_OLD_TIME =
        this.snapshotTime + time.duration.seconds(30)
      const SNAPSHOT_MIDDLE_NEW_TIME =
        this.snapshotTime - time.duration.seconds(1)

      const FIRST_SNAPSHOT = this.snapshotTime + time.duration.seconds(60)
      const SECOND_SNAPSHOT = this.snapshotTime + time.duration.seconds(90)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_MIDDLE_OLD_TIME)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FIRST_SNAPSHOT)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SECOND_SNAPSHOT)
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(
            SNAPSHOT_MIDDLE_OLD_TIME,
            SNAPSHOT_MIDDLE_NEW_TIME
          )
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'CMTAT_SnapshotModule_SnapshotTimestampBeforePreviousSnapshot'
        )
        .withArgs(SNAPSHOT_MIDDLE_NEW_TIME, this.snapshotTime)

      // Assert
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(4)
      checkArraySnapshot(snapshots, [
        this.snapshotTime,
        SNAPSHOT_MIDDLE_OLD_TIME,
        FIRST_SNAPSHOT,
        SECOND_SNAPSHOT
      ])
    })

    it('reverts when calling from non-owner', async function () {
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.address1)
          .rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, SNAPSHOOTER_ROLE)
    })

    it('reverts when trying to reschedule a snapshot in the past', async function () {
      const NEW_TIME = this.snapshotTime - time.duration.seconds(60)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(this.snapshotTime, NEW_TIME)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'CMTAT_SnapshotModule_SnapshotScheduledInThePast'
        )
        .withArgs(NEW_TIME, (await time.latest()) + time.duration.seconds(1))
    })

    it('reverts when trying to reschedule a snapshot to a snapshot time already existing', async function () {
      const NEW_TIME = this.snapshotTime + time.duration.seconds(60)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(NEW_TIME)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(this.snapshotTime, NEW_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotAlreadyExists'
      )
    })

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      /*
      Arrange: we schedule the snapshot at a new time
      */
      await this.transferEngineMock
        .connect(this.admin)
        .rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime)

      /*
      // Act
      We try to reschedule the previous snapshot
      */
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotNotFound'
      )
      // Assert
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
      expect(snapshots[0]).to.equal(this.newSnapshotTime)
    })

    it('reverts when snapshot is not found', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(90)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(SNAPSHOT_TIME, this.newSnapshotTime)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotNotFound'
      )
    })

    it('reverts if no snapshot exits', async function () {
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .unscheduleLastSnapshot(this.snapshotTime)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_NoSnapshotScheduled'
      )
    })

    it('reverts when snapshot has been processed', async function () {
      const SNAPSHOT_TIME = this.currentTime - time.duration.seconds(60)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .rescheduleSnapshot(SNAPSHOT_TIME, this.newSnapshotTime)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotAlreadyDone'
      )
    })
  })
}
module.exports = ERC20SnapshotModuleCommonRescheduling
