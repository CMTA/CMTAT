const { expect } = require('chai')
const { ZERO_ADDRESS } = require('../utils')

/**
 * The holder set is unordered, so assertions on the listing compare sets, not sequences.
 */
async function holderSet (cmtat) {
  const holders = await cmtat.holders()
  return new Set(holders.map((holder) => holder.toLowerCase()))
}

function expectHolders (actualSet, expectedAddresses) {
  expect(actualSet).to.deep.equal(
    new Set(expectedAddresses.map((address) => address.toLowerCase()))
  )
}

function HolderListModuleCommon () {
  context('HolderList', function () {
    it('testHasNoHolderBeforeAnyMint', async function () {
      expect(await this.cmtat.holderCount()).to.equal('0')
      expect(await this.cmtat.holders()).to.deep.equal([])
      expect(await this.cmtat.holdersInRange(0, 0)).to.deep.equal([])
      expect(await this.cmtat.isHolder(this.address1)).to.equal(false)
    })

    it('testAddsAHolderOnMint', async function () {
      this.logs = await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Assert
      expect(await this.cmtat.holderCount()).to.equal('1')
      expect(await this.cmtat.isHolder(this.address1)).to.equal(true)
      expect(await this.cmtat.holderByIndex(0)).to.equal(this.address1.address)
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'HolderAdded')
        .withArgs(this.address1.address)
    })

    it('testDoesNotAddTheZeroAddressAsHolder', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      await this.cmtat.connect(this.admin)['burn(address,uint256)'](this.address1, 50)
      // Assert - neither the mint source nor the burn sink is a holder
      expect(await this.cmtat.isHolder(ZERO_ADDRESS)).to.equal(false)
      expect(await this.cmtat.holderCount()).to.equal('0')
    })

    it('testRemovesAHolderWhoseBalanceReachesZero', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act
      this.logs = await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, 50)
      // Assert
      expect(await this.cmtat.holderCount()).to.equal('1')
      expect(await this.cmtat.isHolder(this.address1)).to.equal(false)
      expect(await this.cmtat.isHolder(this.address2)).to.equal(true)
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'HolderRemoved')
        .withArgs(this.address1.address)
      await expect(this.logs)
        .to.emit(this.cmtat, 'HolderAdded')
        .withArgs(this.address2.address)
    })

    it('testKeepsBothHoldersOnAPartialTransfer', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act
      await this.cmtat.connect(this.address1).transfer(this.address2, 20)
      // Assert
      expect(await this.cmtat.holderCount()).to.equal('2')
      expectHolders(await holderSet(this.cmtat), [
        this.address1.address,
        this.address2.address
      ])
    })

    it('testDoesNotAddAReceiverOnAZeroValueTransfer', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act
      this.logs = await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, 0)
      // Assert - a zero-value transfer leaves the receiver with a zero balance
      expect(await this.cmtat.isHolder(this.address2)).to.equal(false)
      expect(await this.cmtat.holderCount()).to.equal('1')
      await expect(this.logs).to.not.emit(this.cmtat, 'HolderAdded')
    })

    it('testDoesNotEmitHolderAddedTwiceForAnExistingHolder', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act
      this.logs = await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Assert
      expect(await this.cmtat.holderCount()).to.equal('1')
      await expect(this.logs).to.not.emit(this.cmtat, 'HolderAdded')
    })

    it('testRemovesAHolderOnAFullBurn', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act
      this.logs = await this.cmtat.connect(this.admin)[
        'burn(address,uint256)'
      ](this.address1, 50)
      // Assert
      expect(await this.cmtat.holderCount()).to.equal('0')
      expect(await this.cmtat.isHolder(this.address1)).to.equal(false)
      await expect(this.logs)
        .to.emit(this.cmtat, 'HolderRemoved')
        .withArgs(this.address1.address)
    })

    it('testKeepsAHolderOnAPartialBurn', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act
      await this.cmtat.connect(this.admin)['burn(address,uint256)'](this.address1, 20)
      // Assert
      expect(await this.cmtat.holderCount()).to.equal('1')
      expect(await this.cmtat.isHolder(this.address1)).to.equal(true)
    })

    it('testTracksHoldersOnAForcedTransfer', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act - the forced transfer bypasses transfer(), it must still be tracked
      await this.cmtat
        .connect(this.admin)
        .forcedTransfer(this.address1, this.address2, 50)
      // Assert
      expect(await this.cmtat.isHolder(this.address1)).to.equal(false)
      expect(await this.cmtat.isHolder(this.address2)).to.equal(true)
      expect(await this.cmtat.holderCount()).to.equal('1')
    })

    it('testTracksAHolderWhoseTokensAreFrozen', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      // Act - frozen tokens are still part of the balance
      await this.cmtat.connect(this.admin).freezePartialTokens(this.address1, 50)
      // Assert
      expect(await this.cmtat.isHolder(this.address1)).to.equal(true)
      expect(await this.cmtat.holderCount()).to.equal('1')
    })

    it('testCanReturnAHolderAfterHeBecomesAHolderAgain', async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      await this.cmtat.connect(this.address1).transfer(this.address2, 50)
      // Act
      this.logs = await this.cmtat.connect(this.admin).mint(this.address1, 10)
      // Assert
      expect(await this.cmtat.holderCount()).to.equal('2')
      await expect(this.logs)
        .to.emit(this.cmtat, 'HolderAdded')
        .withArgs(this.address1.address)
    })

    context('Range reads', function () {
      beforeEach(async function () {
        await this.cmtat.connect(this.admin).mint(this.address1, 50)
        await this.cmtat.connect(this.admin).mint(this.address2, 50)
        await this.cmtat.connect(this.admin).mint(this.address3, 50)
        this.expectedHolders = [
          this.address1.address,
          this.address2.address,
          this.address3.address
        ]
      })

      it('testCanReturnTheWholeListInOneWindow', async function () {
        const holders = await this.cmtat.holdersInRange(0, 3)
        expect(holders.length).to.equal(3)
        expectHolders(
          new Set(holders.map((holder) => holder.toLowerCase())),
          this.expectedHolders
        )
      })

      it('testCanWalkTheListWindowByWindow', async function () {
        const holderCount = await this.cmtat.holderCount()
        const stride = 2n
        const collected = []
        for (let from = 0n; from < holderCount; from += stride) {
          // holdersInRange reverts past the end, so clamp the upper bound of the last window
          const to = from + stride < holderCount ? from + stride : holderCount
          const window = await this.cmtat.holdersInRange(from, to)
          collected.push(...window)
        }
        expect(collected.length).to.equal(3)
        expectHolders(
          new Set(collected.map((holder) => holder.toLowerCase())),
          this.expectedHolders
        )
      })

      it('testReturnsExactlyTheRequestedWindowLength', async function () {
        expect((await this.cmtat.holdersInRange(2, 3)).length).to.equal(1)
      })

      it('testReturnsAnEmptyWindowWhenFromEqualsToAtHolderCount', async function () {
        // The terminating window of a paging loop, not an error
        expect(await this.cmtat.holdersInRange(3, 3)).to.deep.equal([])
      })

      it('testReturnsAnEmptyWindowWhenFromEqualsTo', async function () {
        expect(await this.cmtat.holdersInRange(1, 1)).to.deep.equal([])
      })

      it('testCannotReadAWindowBeyondTheHolderCount', async function () {
        await expect(this.cmtat.holdersInRange(0, 4))
          .to.be.revertedWithCustomError(
            this.cmtat,
            'CMTAT_HolderListModule_IndexOutOfBounds'
          )
          .withArgs(4, 3)
      })

      it('testRevertsOnAnInvalidRange', async function () {
        await expect(this.cmtat.holdersInRange(3, 1))
          .to.be.revertedWithCustomError(
            this.cmtat,
            'CMTAT_HolderListModule_InvalidRange'
          )
          .withArgs(3, 1)
      })

      it('testInvalidRangeTakesPrecedenceOverOutOfBounds', async function () {
        // fromIndex > toIndex is checked first, so an inverted range whose bounds
        // also exceed holderCount still reports InvalidRange, not IndexOutOfBounds
        await expect(this.cmtat.holdersInRange(5, 4))
          .to.be.revertedWithCustomError(
            this.cmtat,
            'CMTAT_HolderListModule_InvalidRange'
          )
          .withArgs(5, 4)
      })

      it('testCannotReadAnIndexBeyondTheHolderCount', async function () {
        // The bound is checked by the module, not by the underlying EnumerableSet,
        // so this is a custom error and not a Panic(0x32)
        await expect(this.cmtat.holderByIndex(3))
          .to.be.revertedWithCustomError(
            this.cmtat,
            'CMTAT_HolderListModule_IndexOutOfBounds'
          )
          .withArgs(3, 3)
      })

      it('testHoldersMatchesTheRangeListing', async function () {
        expectHolders(await holderSet(this.cmtat), this.expectedHolders)
      })

      it('testHoldersEqualsHoldersInRangeOverTheWholeSet', async function () {
        // holders() is exactly holdersInRange(0, holderCount())
        const count = await this.cmtat.holderCount()
        expect(await this.cmtat.holdersInRange(0, count)).to.deep.equal(
          await this.cmtat.holders()
        )
      })

      it('testHoldersAgreesWithHolderByIndexOnOrdering', async function () {
        const holders = await this.cmtat.holders()
        for (let index = 0; index < holders.length; ++index) {
          expect(await this.cmtat.holderByIndex(index)).to.equal(holders[index])
        }
      })
    })
  })
}

module.exports = HolderListModuleCommon
