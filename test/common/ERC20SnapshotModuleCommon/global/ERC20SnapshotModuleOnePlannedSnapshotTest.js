const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const {
  checkSnapshot
} = require('../ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')
const reason = 'BURN_TEST'

function ERC20SnapshotModuleOnePlannedSnapshotTest () {
  const ADDRESSES = [this.address1, this.address2, this.address3]
  const ADDRESS1_INITIAL_MINT = '31'
  const ADDRESS2_INITIAL_MINT = '32'
  const ADDRESS3_INITIAL_MINT = '33'
  const TOTAL_SUPPLY_INITIAL_MINT = '96'
  context('OnePlannedSnapshotTest', function () {
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
      this.snapshotTime = this.currentTime + time.duration.seconds(3)
      this.beforeSnapshotTime = this.currentTime - time.duration.seconds(60)
      await this.transferEngineMock
        .connect(this.admin)
        .scheduleSnapshot(this.snapshotTime)
      // We jump into the future
      await time.increase(time.duration.seconds(10))
    })

    it('testCanMintTokens', async function () {
      const MINT_AMOUNT = '20'
      // Arrange - Assert
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      );
      // Act
      // Gas and gasPrice are fixed arbitrarily
      ({ logs: this.logs } = await this.cmtat
        .connect(this.admin)
        .mint(this.address1, MINT_AMOUNT, {
          gas: 5000000,
          gasPrice: 500000000
        }))

      // Assert
      // Values before the snapshot
      // await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Value at the time of the snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values now
      const address1NewTokensBalance = (
        Number(ADDRESS1_INITIAL_MINT) + Number(MINT_AMOUNT)
      ).toString()
      const newTotalSupply = (
        Number(TOTAL_SUPPLY_INITIAL_MINT) + Number(MINT_AMOUNT)
      ).toString()
      await checkSnapshot.call(
        this,
        await time.latest(),
        newTotalSupply,
        ADDRESSES,
        [address1NewTokensBalance, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(0)
    })

    it('testCanBurnTokens', async function () {
      const BURN_AMOUNT = '20'
      // Arrange - Assert
      await checkSnapshot.call(
        this,
        await time.latest(),
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )

      // Act
      await this.cmtat
        .connect(this.admin)
        .burn(this.address1, BURN_AMOUNT, reason, {
          gas: 5000000,
          gasPrice: 500000000
        })

      // Assert
      // Values before the snapshot
      // await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Value at the time of the snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values now
      const address1NewTokensBalance = (
        Number(ADDRESS1_INITIAL_MINT) - Number(BURN_AMOUNT)
      ).toString()
      const newTotalSupply = (
        Number(TOTAL_SUPPLY_INITIAL_MINT) - Number(BURN_AMOUNT)
      ).toString()
      await checkSnapshot.call(
        this,
        await time.latest(),
        newTotalSupply,
        ADDRESSES,
        [address1NewTokensBalance, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      const snapshots = await this.transferEngineMock.getNextSnapshots()
      expect(snapshots.length).to.equal(0)
    })

    it('testCanTransferTokens', async function () {
      const TRANSFER_AMOUNT = '20'
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
        .transfer(this.address2, TRANSFER_AMOUNT, {
          gas: 5000000,
          gasPrice: 500000000
        })

      // Assert
      // Values before the snapshot
      // await checkSnapshot.call(this, this.beforeSnapshotTime, TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      // Value at the time of the snapshot
      await checkSnapshot.call(
        this,
        this.snapshotTime,
        TOTAL_SUPPLY_INITIAL_MINT,
        ADDRESSES,
        [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
      )
      // Values now
      const address1NewTokensBalance = (
        Number(ADDRESS1_INITIAL_MINT) - Number(TRANSFER_AMOUNT)
      ).toString()
      const address2NewTokensBalance = (
        Number(ADDRESS2_INITIAL_MINT) + Number(TRANSFER_AMOUNT)
      ).toString()
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
  })
}
module.exports = ERC20SnapshotModuleOnePlannedSnapshotTest
