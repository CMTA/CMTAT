const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../../../utils')
const { should } = require('chai').should()
const { getUnixTimestamp, timeout, checkSnapshot } = require('../SnapshotModuleUtils/SnapshotModuleUtils')
const reason = 'BURN_TEST'

function SnapshotModuleOnePlannedSnapshotTest (admin, address1, address2, address3) {
  const ADDRESSES = [address1, address2, address3]
  const ADDRESS1_INITIAL_MINT = '31'
  const ADDRESS2_INITIAL_MINT = '32'
  const ADDRESS3_INITIAL_MINT = '33'
  const TOTAL_SUPPLY_INITIAL_MINT = '96'
  context('OnePlannedSnapshotTest', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_MINT, { from: admin })
      this.snapshotTime = `${getUnixTimestamp() + 1}`
      this.beforeSnapshotTime = `${getUnixTimestamp() - 60}`
      await this.cmtat.scheduleSnapshot(this.snapshotTime, { from: admin })
      // We jump into the future
      await timeout(3000)
    })

    it('testCanMintTokens', async function () {
      const MINT_AMOUNT = '20'
      // Arrange - Assert
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])

      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.mint(address1, MINT_AMOUNT, {
        from: admin,
        gas: 5000000,
        gasPrice: 500000000
      })

      // Assert
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Value at the time of the snapshot
      await checkSnapshot.call(this, this.snapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values now
      const address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) + Number(MINT_AMOUNT)).toString()
      const newTotalSupply = (Number(TOTAL_SUPPLY_INITIAL_MINT) + Number(MINT_AMOUNT)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), newTotalSupply, ADDRESSES, [address1NewTokensBalance, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })

    it('testCanBurnTokens', async function () {
      const BURN_AMOUNT = '20'
      // Arrange - Assert
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]);

      // Act
      (await this.cmtat.forceBurn(address1, BURN_AMOUNT, reason, {
        from: admin,
        gas: 5000000,
        gasPrice: 500000000
      }))

      // Assert
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Value at the time of the snapshot
      await checkSnapshot.call(this, this.snapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values now
      const address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(BURN_AMOUNT)).toString()
      const newTotalSupply = (Number(TOTAL_SUPPLY_INITIAL_MINT) - Number(BURN_AMOUNT)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), newTotalSupply, ADDRESSES, [address1NewTokensBalance, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })

    it('testCanTransferTokens', async function () {
      const TRANSFER_AMOUNT = '20'
      // Arrange - Assert
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])

      // Act
      // Gas and gasPrice are fixed arbitrarily
      await this.cmtat.transfer(address2, TRANSFER_AMOUNT, {
        from: address1,
        gas: 5000000,
        gasPrice: 500000000
      })

      // Assert
      // Values before the snapshot
      await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Value at the time of the snapshot
      await checkSnapshot.call(this, this.snapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Values now
      const address1NewTokensBalance = (Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT)).toString()
      const address2NewTokensBalance = (Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT)).toString()
      await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [address1NewTokensBalance, address2NewTokensBalance, ADDRESS3_INITIAL_MINT])
      const snapshots = await this.cmtat.getNextSnapshots()
      snapshots.length.should.equal(0)
    })
  })
}
module.exports = SnapshotModuleOnePlannedSnapshotTest
