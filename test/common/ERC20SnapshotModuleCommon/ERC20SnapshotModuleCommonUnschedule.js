const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const {
  checkArraySnapshot
} = require('./ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')

function ERC20SnapshotModuleCommonUnschedule () {
  context('unscheduleSnapshotNotOptimized', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      this.snapshotTime1 = this.currentTime + time.duration.seconds(10)
      this.snapshotTime2 = this.currentTime + time.duration.seconds(15)
      this.snapshotTime3 = this.currentTime + time.duration.seconds(20)
      this.snapshotTime4 = this.currentTime + time.duration.seconds(25)
      this.snapshotTime5 = this.currentTime + time.duration.seconds(30)
      this.snapshotTime6 = this.currentTime + time.duration.seconds(40)
    })

    it('can remove a snapshot as admin', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(60)
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_TIME)
      let snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
      expect(snapshots[0]).to.equal(SNAPSHOT_TIME)
      await this.transferEngineMock
        .connect(this.admin)
        .unscheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(0)
    })
    it('can remove a random snapshot with the snapshoter role', async function () {
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime4)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime5)
      let snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(5)
      await this.transferEngineMock
        .connect(this.admin)
        .unscheduleSnapshotNotOptimized(this.snapshotTime3)
      snapshots = await this.transferEngineMock.getNextSnapshots()
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.snapshotTime3,
        this.snapshotTime4
      ])
      expect(snapshots.length).to.equal(4)
    })
    it('Revert if no snapshot', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(60)
      let snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(0)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .unscheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotNotFound'
      )
      snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(0)
    })

    it('testCannotUnscheduleASnapshotInThePast', async function () {
      const SNAPSHOT_TIME = this.currentTime - time.duration.seconds(60)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .unscheduleLastSnapshot(SNAPSHOT_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotAlreadyDone'
      )
    })

    it('can unschedule a snaphot in a random place', async function () {
      const RANDOM_SNAPSHOT = this.currentTime + time.duration.seconds(17)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime4)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime5)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshotNotOptimized(RANDOM_SNAPSHOT)
      let snapshots = await this.transferEngineMock.getNextSnapshots()
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.RANDOM_SNAPSHOT,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5
      ])
      expect(snapshots.length).to.equal(6)
      await this.transferEngineMock
        .connect(this.admin)
        .unscheduleSnapshotNotOptimized(RANDOM_SNAPSHOT)
      snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(5)
      snapshots = await this.transferEngineMock.getNextSnapshots()
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime2,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5
      ])
    })

    it('can schedule a snaphot after an unschedule', async function () {
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime4)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime5)
      let snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(5)
      await this.transferEngineMock
        .connect(this.admin)
        .unscheduleSnapshotNotOptimized(this.snapshotTime2)
      snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(4)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime6)
      snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(5)
      checkArraySnapshot(snapshots, [
        this.snapshotTime1,
        this.snapshotTime3,
        this.snapshotTime4,
        this.snapshotTime5,
        this.snapshotTime6
      ])
    })

    it('reverts when calling from non-admin', async function () {
      // Arrange
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(60)
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_TIME)
      let snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
      expect(snapshots[0]).to.equal(SNAPSHOT_TIME)
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.address1)
          .unscheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, SNAPSHOOTER_ROLE)
      // Assert
      snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
    })
  })

  context('Snapshot unscheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      this.snapshotTime = this.currentTime + time.duration.seconds(60)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime)
    })

    it('can unschedule a snapshot with the snapshoter role and emits a SnapshotUnschedule event', async function () {
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .unscheduleLastSnapshot(this.snapshotTime)
      await expect(this.logs)
        .to.emit(this.transferEngineMock, 'SnapshotUnschedule')
        .withArgs(this.snapshotTime)
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(0)
    })

    it('reverts when calling from non-admin', async function () {
      await expect(
        this.transferEngineMock
          .connect(this.address1)
          .unscheduleLastSnapshot(this.snapshotTime)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, SNAPSHOOTER_ROLE)
    })

    it('reverts if no snapshot is scheduled', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(90)
      // Arrange
      // Delete the only snapshot
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .unscheduleLastSnapshot(this.snapshotTime)
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .unscheduleLastSnapshot(SNAPSHOT_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_NoSnapshotScheduled'
      )
    })

    it('reverts when snapshot is not found', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(90)
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .unscheduleLastSnapshot(SNAPSHOT_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotNotFound'
      )
    })

    it('reverts when snapshot has been processed', async function () {
      const SNAPSHOT_TIME = this.currentTime - time.duration.seconds(60)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .unscheduleLastSnapshot(SNAPSHOT_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotAlreadyDone'
      )
    })
  })
}
module.exports = ERC20SnapshotModuleCommonUnschedule
