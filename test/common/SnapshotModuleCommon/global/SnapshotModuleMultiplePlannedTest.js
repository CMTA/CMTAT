const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { getUnixTimestamp, timeout, checkSnapshot } = require('../SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleMultiplePlannedTest (admin, address1, address2, address3) {
  // With multiple planned snapshot
  context('SnapshotMultiplePlannedTest', function () {
    const ADDRESSES = [address1, address2, address3]
    const ADDRESS1_INITIAL_MINT = '31'
    const ADDRESS2_INITIAL_MINT = '32'
    const ADDRESS3_INITIAL_MINT = '33'
    const TOTAL_SUPPLY_INITIAL_MINT = '96'
    beforeEach(async function () {
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_MINT, { from: admin })
      this.snapshotTime1 = `${getUnixTimestamp() + 1}`
      this.snapshotTime2 = `${getUnixTimestamp() + 6}`
      this.snapshotTime3 = `${getUnixTimestamp() + 11}`
      this.beforeSnapshotTime = `${getUnixTimestamp() - 60}`
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
      await timeout(3000)
    })

    it('testCanTransferTokensAfterFirstSnapshot', async function () {
      const TRANSFER_AMOUNT_1 = '20'
      // Arrange - Assert
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])

      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
        gas: 5000000,
        gasPrice: 500000000
      })
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // values at the time of the first snapshot
      await checkSnapshot.call(this, this.snapshotTime1, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // values now
      const address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1)).toString()
      const address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
    })

    it('testCanTransferAfterSecondSnapshot', async function () {
      const TRANSFER_AMOUNT_1 = '20'
      // We jump into the future
      await timeout(5000)
      // Arrange - Assert
      // No transfer performed since the minting
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])

      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
        gas: 5000000,
        gasPrice: 500000000
      })
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the first snapshot
      await checkSnapshot.call(this, this.snapshotTime1, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the second snapshot
      await checkSnapshot.call(this, this.snapshotTime2, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // values now
      const address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1)).toString()
      const address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(1)
    })

    it('testCanTransferAfterThirdSnapshot', async function () {
      const TRANSFER_AMOUNT_1 = '20'
      // We jump into the future
      await timeout(10000)
      // Arrange - Assert
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
        gas: 5000000,
        gasPrice: 500000000
      })
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the first snapshot
      await checkSnapshot.call(this, this.snapshotTime1, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the second snapshot
      await checkSnapshot.call(this, this.snapshotTime2, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the third snapshot
      await checkSnapshot.call(this, this.snapshotTime3, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values now
      const address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1)).toString()
      const address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })

    it('testCanTransferTokensMultipleTimes', async function () {
      const TRANSFER_AMOUNT_1 = '20'
      const TRANSFER_AMOUNT_2 = '10'
      const TRANSFER_AMOUNT_3 = '5'
      // Arrange - Assert
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])

      // **********Act**************** */
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_1, {
        from: address1,
        gas: 5000000,
        gasPrice: 500000000
      })
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the first snapshot
      await checkSnapshot.call(this, this.snapshotTime1, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      let address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1)).toString()
      let address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1)).toString()
      // Values at the time of the second snapshot
      await checkSnapshot.call(this, this.snapshotTime2, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      // Values at the time of the third snapshot
      await checkSnapshot.call(this, this.snapshotTime3, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      // Values now
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT]);
      (await this.cmtat.getNextSnapshots()).length.should.equal(2)
      // We jump into the future
      await timeout(5000)
      // **********Act**************** */
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address1, TRANSFER_AMOUNT_2, {
        from: address2,
        gas: 5000000,
        gasPrice: 500000000
      })
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the first snapshot
      await checkSnapshot.call(this, this.snapshotTime1, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the second snapshot
      address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1)).toString()
      address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1)).toString()
      await checkSnapshot.call(this, this.snapshotTime2, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      // Values now
      address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1) + Number(TRANSFER_AMOUNT_2)).toString()
      address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1) - Number(TRANSFER_AMOUNT_2)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT]);
      (await this.cmtat.getNextSnapshots()).length.should.equal(1)
      // We jump into the future
      await timeout(5000)

      // **********Act**************** */
      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT_3, {
        from: address1,
        gas: 5000000,
        gasPrice: 500000000
      })
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the first snapshot
      checkSnapshot.call(this, this.snapshotTime1, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values at the time of the second snapshot
      address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1)).toString()
      address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1)).toString()
      await checkSnapshot.call(this, this.snapshotTime2, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      // Values at the time of the third snapshot
      address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1) + Number(TRANSFER_AMOUNT_2)).toString()
      address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1) - Number(TRANSFER_AMOUNT_2)).toString()
      await checkSnapshot.call(this, this.snapshotTime3, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      // Values now
      address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT_1) + Number(TRANSFER_AMOUNT_2) - Number(TRANSFER_AMOUNT_3)).toString()
      address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT_1) - Number(TRANSFER_AMOUNT_2) + Number(TRANSFER_AMOUNT_3)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT]);
      (await this.cmtat.getNextSnapshots()).length.should.equal(0)
    })
  })
}
module.exports = SnapshotModuleMultiplePlannedTest
