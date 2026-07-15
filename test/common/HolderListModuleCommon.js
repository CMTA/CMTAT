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
      expect(await this.cmtat.holdersByPage(0, 10)).to.deep.equal([])
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

    context('Pagination', function () {
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

      it('testCanReturnTheWholeListInOnePage', async function () {
        const holders = await this.cmtat.holdersByPage(0, 3)
        expect(holders.length).to.equal(3)
        expectHolders(
          new Set(holders.map((holder) => holder.toLowerCase())),
          this.expectedHolders
        )
      })

      it('testCanWalkTheListPageByPage', async function () {
        const holderCount = await this.cmtat.holderCount()
        const collected = []
        for (let offset = 0n; offset < holderCount; offset += 2n) {
          const page = await this.cmtat.holdersByPage(offset, 2)
          collected.push(...page)
        }
        expect(collected.length).to.equal(3)
        expectHolders(
          new Set(collected.map((holder) => holder.toLowerCase())),
          this.expectedHolders
        )
      })

      it('testTruncatesTheLastPageToTheRemainingHolders', async function () {
        const page = await this.cmtat.holdersByPage(2, 10)
        expect(page.length).to.equal(1)
      })

      it('testReturnsAnEmptyPageWhenOffsetEqualsHolderCount', async function () {
        // The terminating page of a paging loop, not an error
        expect(await this.cmtat.holdersByPage(3, 10)).to.deep.equal([])
      })

      it('testReturnsAnEmptyPageWhenLimitIsZero', async function () {
        expect(await this.cmtat.holdersByPage(0, 0)).to.deep.equal([])
      })

      it('testCannotReadAPageBeyondTheHolderCount', async function () {
        await expect(this.cmtat.holdersByPage(4, 10))
          .to.be.revertedWithCustomError(
            this.cmtat,
            'CMTAT_HolderListModule_OffsetOutOfBounds'
          )
          .withArgs(4, 3)
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

      it('testHoldersMatchesThePaginatedListing', async function () {
        expectHolders(await holderSet(this.cmtat), this.expectedHolders)
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
