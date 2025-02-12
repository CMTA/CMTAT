const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const {
  checkSnapshot
} = require('../ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')

function ERC20SnapshotModuleMultiplePlannedTest () {
  // With multiple planned snapshot
  context('SnapshotMultiplePlannedTest', function () {
    const ADDRESSES = [this.address1, this.address2, this.address3]
    const ADDRESS1_INITIAL_MINT = 31n
    const ADDRESS2_INITIAL_MINT = 32n
    const ADDRESS3_INITIAL_MINT = 33n
    const TOTAL_SUPPLY_INITIAL_MINT = 96n
    const FIRST_SNAPSHOT_INTERVAL = 4
    const SECOND_SNAPSHOT_INTERVAL = 10
    const THIRD_SNAPSHOT_INTERVAL = 20
    const TRANSFER_AMOUNT_1 = 20n
    const TRANSFER_AMOUNT_2 = 10n
    const TRANSFER_AMOUNT_3 = 5n
    beforeEach(async function () {
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, ADDRESS1_INITIAL_MINT)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, ADDRESS2_INITIAL_MINT)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, ADDRESS3_INITIAL_MINT)
      this.currentTime = await time.latest()
      this.snapshotTime1 =
        this.currentTime + time.duration.seconds(FIRST_SNAPSHOT_INTERVAL)
      this.snapshotTime2 =
        this.currentTime + time.duration.seconds(SECOND_SNAPSHOT_INTERVAL)
      this.snapshotTime3 =
        this.currentTime + time.duration.seconds(THIRD_SNAPSHOT_INTERVAL)
      this.beforeSnapshotTime = this.currentTime - time.duration.seconds(60)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime1)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime2)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime3)
      // We jump into the future
      await time.increase(FIRST_SNAPSHOT_INTERVAL + 1)
    })

    it('testCanTransferTokensAfterFirstSnapshot', async function () {
      const TRANSFER_AMOUNT_1 = 20n
      // Arrange - Assert
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )

      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, TRANSFER_AMOUNT_1, {
          gas: 5000000,
          gasPrice: 500000000
        })
      // Values before the snapshot
      await checkSnapshot.call(
        this,
        this.beforeSnapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // values at the time of the first snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime1,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // values now
      const address1NewTokensBalance =
        ADDRESS1_INITIAL_MINT - TRANSFER_AMOUNT_1
      const address2NewTokensBalance =
        ADDRESS2_INITIAL_MINT + TRANSFER_AMOUNT_1
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          address1NewTokensBalance,
          address2NewTokensBalance,
          ADDRESS3_INITIAL_MINT
        ]
      )
    })

    it('testCanTransferAfterSecondSnapshot', async function () {
      // We jump into the future
      await time.increase(SECOND_SNAPSHOT_INTERVAL - FIRST_SNAPSHOT_INTERVAL)
      // Arrange - Assert
      // No transfer performed since the minting
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )

      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, TRANSFER_AMOUNT_1, {
          gas: 5000000,
          gasPrice: 500000000
        })
      // Values before the snapshot
      await checkSnapshot.call(
        this,
        this.beforeSnapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the first snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime1,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the second snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime2,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // values now
      const address1NewTokensBalance =
        ADDRESS1_INITIAL_MINT - TRANSFER_AMOUNT_1
      const address2NewTokensBalance =
        ADDRESS2_INITIAL_MINT + TRANSFER_AMOUNT_1
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          address1NewTokensBalance,
          address2NewTokensBalance,
          ADDRESS3_INITIAL_MINT
        ]
      )
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(1)
    })

    it('testCanTransferAfterThirdSnapshot', async function () {
      // We jump into the future
      await time.increase(THIRD_SNAPSHOT_INTERVAL - FIRST_SNAPSHOT_INTERVAL)
      // Arrange - Assert
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, TRANSFER_AMOUNT_1, {
          gas: 5000000,
          gasPrice: 500000000
        })
      // Values before the snapshot
      await checkSnapshot.call(
        this,
        this.beforeSnapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the first snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime1,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the second snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime2,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the third snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime3,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values now
      const address1NewTokensBalance =
        ADDRESS1_INITIAL_MINT - TRANSFER_AMOUNT_1
      const address2NewTokensBalance =
        ADDRESS2_INITIAL_MINT + TRANSFER_AMOUNT_1
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          address1NewTokensBalance,
          address2NewTokensBalance,
          ADDRESS3_INITIAL_MINT
        ]
      )
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(0)
    })

    it('testCanTransferTokensMultipleTimes', async function () {
      // Arrange - Assert
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )

      // **********Act**************** */
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, TRANSFER_AMOUNT_1, {
          gas: 5000000,
          gasPrice: 500000000
        })
      // Values before the snapshot
      await checkSnapshot.call(
        this,
        this.beforeSnapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the first snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime1,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      const ADDRESS1_BALANCE_AFTER_ONE_TRANSFER =
        ADDRESS1_INITIAL_MINT - TRANSFER_AMOUNT_1
      const ADDRESS2_BALANCE_AFTER_TONE_TRANSFER =
        ADDRESS2_INITIAL_MINT + TRANSFER_AMOUNT_1
      // Values at the time of the second snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime2,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_ONE_TRANSFER,
          ADDRESS2_BALANCE_AFTER_TONE_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      // Values at the time of the third snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime3,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_ONE_TRANSFER,
          ADDRESS2_BALANCE_AFTER_TONE_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      // Values now
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_ONE_TRANSFER,
          ADDRESS2_BALANCE_AFTER_TONE_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      expect(
        (await this.transferEngineMock.getNextSnapshots()).length
      ).to.equal(2)
      // We jump into the future
      await time.increase(SECOND_SNAPSHOT_INTERVAL - FIRST_SNAPSHOT_INTERVAL)

      // **********Act**************** */
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat
        .connect(this.address2)
        .transfer(this.address1, TRANSFER_AMOUNT_2, {
          gas: 5000000,
          gasPrice: 500000000
        })
      // Values before the snapshot
      await checkSnapshot.call(
        this,
        this.beforeSnapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the first snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime1,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the second snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime2,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_ONE_TRANSFER,
          ADDRESS2_BALANCE_AFTER_TONE_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      // Values now
      const ADDRESS1_BALANCE_AFTER_TWO_TRANSFER =
        ADDRESS1_BALANCE_AFTER_ONE_TRANSFER + TRANSFER_AMOUNT_2
      const ADDRESS2_BALANCE_AFTER_TWO_TRANSFER =
        ADDRESS2_BALANCE_AFTER_TONE_TRANSFER - TRANSFER_AMOUNT_2
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_TWO_TRANSFER,
          ADDRESS2_BALANCE_AFTER_TWO_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      expect(
        (await this.transferEngineMock.getNextSnapshots()).length
      ).to.equal(1)
      // We jump into the future
      await time.increase(THIRD_SNAPSHOT_INTERVAL - FIRST_SNAPSHOT_INTERVAL)

      // **********Act**************** */
      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, TRANSFER_AMOUNT_3, {
          gas: 5000000,
          gasPrice: 500000000
        })
      // Values before the snapshot
      await checkSnapshot.call(
        this,
        this.beforeSnapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the first snapshot
      checkSnapshot.call(
        this,
        this.snapshotTime1,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values at the time of the second snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime2,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_ONE_TRANSFER,
          ADDRESS2_BALANCE_AFTER_TONE_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      // Values at the time of the third snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime3,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_TWO_TRANSFER,
          ADDRESS2_BALANCE_AFTER_TWO_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      // Values now
      const ADDRESS1_BALANCE_AFTER_THREE_TRANSFER =
        ADDRESS1_BALANCE_AFTER_ONE_TRANSFER + TRANSFER_AMOUNT_3
      const ADDRESS2_BALANCE_AFTER_THREE_TRANSFER =
        ADDRESS2_BALANCE_AFTER_TONE_TRANSFER - TRANSFER_AMOUNT_3
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [
          ADDRESS1_BALANCE_AFTER_THREE_TRANSFER,
          ADDRESS2_BALANCE_AFTER_THREE_TRANSFER,
          ADDRESS3_INITIAL_MINT
        ]
      )
      expect(
        (await this.transferEngineMock.getNextSnapshots()).length
      ).to.equal(0)
    })
  })
}
module.exports = ERC20SnapshotModuleMultiplePlannedTest
