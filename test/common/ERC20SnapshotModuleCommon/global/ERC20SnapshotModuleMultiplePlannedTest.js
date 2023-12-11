const { time, BN } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { checkSnapshot } = require('../ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')

function ERC20SnapshotModuleMultiplePlannedTest (
  admin,
  address1,
  address2,
  address3
) {
  // With multiple planned snapshot
  context('SnapshotMultiplePlannedTest', function () {
    const ADDRESSES = [address1, address2, address3]
    const ADDRESS1_INITIAL_MINT = BN(31)
    const ADDRESS2_INITIAL_MINT = BN(32)
    const ADDRESS3_INITIAL_MINT = BN(33)
    const TOTAL_SUPPLY_INITIAL_MINT = BN(96)
    const FIRST_SNAPSHOT_INTERVAL = BN(4)
    const SECOND_SNAPSHOT_INTERVAL = BN(10)
    const THIRD_SNAPSHOT_INTERVAL = BN(20)
    const TRANSFER_AMOUNT_1 = BN(20)
    const TRANSFER_AMOUNT_2 = BN(10)
    const TRANSFER_AMOUNT_3 = BN(5)
    beforeEach(async function () {
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_MINT, { from: admin })
      this.currentTime = await time.latest()
      this.snapshotTime1 = this.currentTime.add(
        time.duration.seconds(FIRST_SNAPSHOT_INTERVAL)
      )
      this.snapshotTime2 = this.currentTime.add(
        time.duration.seconds(SECOND_SNAPSHOT_INTERVAL)
      )
      this.snapshotTime3 = this.currentTime.add(
        time.duration.seconds(THIRD_SNAPSHOT_INTERVAL)
      )
      this.beforeSnapshotTime = this.currentTime.sub(time.duration.seconds(60))
      await this.cmtat.scheduleSnapshot(this.snapshotTime1, {
        from: admin
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime2, {
        from: admin
      })
      await this.cmtat.scheduleSnapshot(this.snapshotTime3, {
        from: admin
      })
      // We jump into the future
      await time.increase(FIRST_SNAPSHOT_INTERVAL.add(BN(1)))
    })

    it('testCanTransferTokensAfterFirstSnapshot', async function () {
      const TRANSFER_AMOUNT_1 = BN(20)
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
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
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
        ADDRESS1_INITIAL_MINT.sub(TRANSFER_AMOUNT_1)
      const address2NewTokensBalance =
        ADDRESS2_INITIAL_MINT.add(TRANSFER_AMOUNT_1)
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
      await time.increase(
        SECOND_SNAPSHOT_INTERVAL.sub(FIRST_SNAPSHOT_INTERVAL)
      )
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
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
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
        ADDRESS1_INITIAL_MINT.sub(TRANSFER_AMOUNT_1)
      const address2NewTokensBalance =
        ADDRESS2_INITIAL_MINT.add(TRANSFER_AMOUNT_1)
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
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
    })

    it('testCanTransferAfterThirdSnapshot', async function () {
      // We jump into the future
      await time.increase(THIRD_SNAPSHOT_INTERVAL.sub(FIRST_SNAPSHOT_INTERVAL))
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
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
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
        ADDRESS1_INITIAL_MINT.sub(TRANSFER_AMOUNT_1)
      const address2NewTokensBalance =
        ADDRESS2_INITIAL_MINT.add(TRANSFER_AMOUNT_1)
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
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
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
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
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
        ADDRESS1_INITIAL_MINT.sub(TRANSFER_AMOUNT_1)
      const ADDRESS2_BALANCE_AFTER_TONE_TRANSFER =
        ADDRESS2_INITIAL_MINT.add(TRANSFER_AMOUNT_1)
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
      );
      (await this.cmtat.getNextSnapshots()).length.should.equal(2)
      // We jump into the future
      await time.increase(
        SECOND_SNAPSHOT_INTERVAL.sub(FIRST_SNAPSHOT_INTERVAL)
      )

      // **********Act**************** */
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address1, TRANSFER_AMOUNT_2, {
        from: address2,
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
        ADDRESS1_BALANCE_AFTER_ONE_TRANSFER.add(TRANSFER_AMOUNT_2)
      const ADDRESS2_BALANCE_AFTER_TWO_TRANSFER =
        ADDRESS2_BALANCE_AFTER_TONE_TRANSFER.sub(TRANSFER_AMOUNT_2)
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
      );
      (await this.cmtat.getNextSnapshots()).length.should.equal(1)
      // We jump into the future
      await time.increase(THIRD_SNAPSHOT_INTERVAL.sub(FIRST_SNAPSHOT_INTERVAL))

      // **********Act**************** */
      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_3, {
        from: address1,
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
        ADDRESS1_BALANCE_AFTER_ONE_TRANSFER.add(TRANSFER_AMOUNT_3)
      const ADDRESS2_BALANCE_AFTER_THREE_TRANSFER =
        ADDRESS2_BALANCE_AFTER_TONE_TRANSFER.sub(TRANSFER_AMOUNT_3)
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
      );
      (await this.cmtat.getNextSnapshots()).length.should.equal(0)
    })
  })
}
module.exports = ERC20SnapshotModuleMultiplePlannedTest