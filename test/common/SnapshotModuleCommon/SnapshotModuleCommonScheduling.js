const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { SNAPSHOOTER_ROLE, ZERO_ADDRESS } = require('../../utils')
const {
  checkArraySnapshot
} = require('./SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonScheduling () {
  context('Snapshot scheduling', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      if ((await this.cmtat.snapshotEngine()) === ZERO_ADDRESS) {
        this.transferEngineMock = await ethers.deployContract(
          'SnapshotEngineMock',
          [this.cmtat.target, this.admin]
        )
        this.cmtat
          .connect(this.admin)
          .setSnapshotEngine(this.transferEngineMock)
      }
    })
    it('can schedule a snapshot with the snapshoter role', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(60)
      // Act
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_TIME)
      // Assert
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
      expect(snapshots[0]).to.equal(SNAPSHOT_TIME)

      // emits a SnapshotSchedule event
      await expect(this.logs)
        .to.emit(this.transferEngineMock, 'SnapshotSchedule')
        .withArgs('0', SNAPSHOT_TIME)
    })

    it('reverts when calling from non-admin', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(60)
      await expect(
        this.transferEngineMock
          .connect(this.address1)
          .scheduleSnapshot(SNAPSHOT_TIME)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, SNAPSHOOTER_ROLE)
    })

    it('reverts when trying to schedule a snapshot before the last snapshot', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(120)
      // Act
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_TIME)
      const SNAPSHOT_TIME_INVALID = SNAPSHOT_TIME - time.duration.seconds(60)

      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .scheduleSnapshot(SNAPSHOT_TIME_INVALID)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'CMTAT_SnapshotModule_SnapshotTimestampBeforeLastSnapshot'
        )
        .withArgs(SNAPSHOT_TIME_INVALID, SNAPSHOT_TIME)
    })

    it('reverts when trying to schedule a snapshot in the past', async function () {
      const SNAPSHOT_TIME = this.currentTime - time.duration.seconds(60)
      if (!this.dontCheckTimestamp) {
        await expect(
          this.transferEngineMock
            .connect(this.admin)
            .scheduleSnapshot(SNAPSHOT_TIME)
        )
          .to.be.revertedWithCustomError(
            this.transferEngineMock,
            'CMTAT_SnapshotModule_SnapshotScheduledInThePast'
          )
          .withArgs(
            SNAPSHOT_TIME,
            (await time.latest()) + time.duration.seconds(1)
          )
      } else {
        await expect(
          this.transferEngineMock
            .connect(this.admin)
            .scheduleSnapshot(SNAPSHOT_TIME)
        ).to.be.reverted
      }
    })

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(60)
      // Arrange
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SNAPSHOT_TIME)
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .scheduleSnapshot(SNAPSHOT_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotAlreadyExists'
      )
      // Assert
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
      expect(snapshots[0]).to.equal(SNAPSHOT_TIME)
    })
  })

  context('Snapshot scheduling NotOptimized', function () {
    beforeEach(async function () {
      this.currentTime = await time.latest()
      if ((await this.cmtat.snapshotEngine()) === ZERO_ADDRESS) {
        this.transferEngineMock = await ethers.deployContract(
          'SnapshotEngineMock',
          [this.cmtat.target, this.admin]
        )
        this.cmtat
          .connect(this.admin)
          .setSnapshotEngine(this.transferEngineMock)
      }
    })
    it('can schedule a snapshot in the first place with the snapshoter role', async function () {
      const baseTime = await time.latest()
      const FIRST_SNAPSHOT = baseTime + time.duration.seconds(3600)
      const SECOND_SNAPSHOT = baseTime + time.duration.seconds(7200)
      const THIRD_SNAPSHOT = baseTime + time.duration.seconds(1800)
      // Arrange
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FIRST_SNAPSHOT)
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SECOND_SNAPSHOT)
      // Act
      // We schedule the snapshot at the first place
      this.snapshotTime = baseTime + time.duration.seconds(1200)
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshotNotOptimized(THIRD_SNAPSHOT)
      // Assert
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(3)
      expect(snapshots[0]).to.equal(THIRD_SNAPSHOT)
    })

    it('can schedule a snaphot in a random place', async function () {
      const baseTime = await time.latest()
      // Arrange
      const FIRST_SNAPSHOT = baseTime + time.duration.seconds(3600)
      const SECOND_SNAPSHOT = baseTime + time.duration.seconds(4200)
      const THIRD_SNAPSHOT = baseTime + time.duration.seconds(4800)
      const FOUR_SNAPSHOT = baseTime + time.duration.seconds(5400)
      const FIVE_SNAPSHOT = baseTime + time.duration.seconds(6000)
      // Third position
      const RANDOM_SNAPSHOT = baseTime + time.duration.seconds(4500)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FIRST_SNAPSHOT)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SECOND_SNAPSHOT)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(THIRD_SNAPSHOT)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FOUR_SNAPSHOT)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FIVE_SNAPSHOT)
      // Act
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshotNotOptimized(RANDOM_SNAPSHOT)
      // Assert
      let snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(6)
      snapshots = await this.transferEngineMock.getNextSnapshots()
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
      const SNAPSHOT_TIME = (await time.latest()) + time.duration.seconds(3600)
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)

      // emits a SnapshotSchedule event
      await expect(this.logs)
        .to.emit(this.transferEngineMock, 'SnapshotSchedule')
        .withArgs('0', SNAPSHOT_TIME)
    })

    it('reverts when calling from non-admin', async function () {
      const SNAPSHOT_TIME = this.currentTime + time.duration.seconds(60)
      await expect(
        this.transferEngineMock
          .connect(this.address1)
          .scheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, SNAPSHOOTER_ROLE)
    })

    it('reverts when trying to schedule a snapshot in the past', async function () {
      const SNAPSHOT_TIME = this.currentTime - time.duration.seconds(60)
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .scheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotScheduledInThePast'
      )
      /* await expect(
        this.transferEngineMock
          .connect(this.admin)
          .scheduleSnapshotNotOptimized(SNAPSHOT_TIME)
      )
        .to.be.revertedWithCustomError(
          this.transferEngineMock,
          'CMTAT_SnapshotModule_SnapshotScheduledInThePast'
        )
        .withArgs(
          SNAPSHOT_TIME,
          (await time.latest()) + time.duration.seconds(1)
        ) */
    })

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      const FIRST_SNAPSHOT = this.currentTime + time.duration.seconds(10)
      const SECOND_SNAPSHOT = this.currentTime + time.duration.seconds(100)
      // Arrange
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(FIRST_SNAPSHOT)
      this.logs = await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(SECOND_SNAPSHOT)
      // Act
      await expect(
        this.transferEngineMock
          .connect(this.admin)
          .scheduleSnapshotNotOptimized(FIRST_SNAPSHOT)
      ).to.be.revertedWithCustomError(
        this.transferEngineMock,
        'CMTAT_SnapshotModule_SnapshotAlreadyExists'
      )
      // Assert
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(2)
      checkArraySnapshot(snapshots, [FIRST_SNAPSHOT, SECOND_SNAPSHOT])
    })
  })
}
module.exports = SnapshotModuleCommonScheduling
