const { expect } = require('chai')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../utils.js')

function ERC20MintModuleCommon () {
  context('Minting', function () {
    const VALUE1 = 20n
    const VALUE2 = 50n
    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      // Arrange

      // Arrange - Assert
      // Check first balance
      expect(await this.cmtat.balanceOf(this.admin)).to.equal(0n)

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(this.admin)
        .mint(this.address1, VALUE1)

      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(VALUE1)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE1)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(this.address1, VALUE1)

      // Act
      // Issue 50 and check intermediate balances and total supply
      this.logs = await this.cmtat
        .connect(this.admin)
        .mint(this.address2, VALUE2)

      // Assert
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(VALUE2)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1 + VALUE2)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address2, VALUE2)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(this.address2, VALUE2)
    })

    it('testCanMintByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address1)
      // Arrange - Assert
      // Check first balance
      expect(await this.cmtat.balanceOf(this.admin)).to.equal(0n)

      // Act
      // Issue 20
      this.logs = await this.cmtat
        .connect(this.address1)
        .mint(this.address1, VALUE1)
      // Assert
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(VALUE1)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE1)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(this.address1, VALUE1)
    })

    // reverts when issuing by a non minter
    it('testCannotMintByNonMinter', async function () {
      await expect(
        this.cmtat.connect(this.address1).mint(this.address1, VALUE1)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, MINTER_ROLE)
    })
  })

  context('Batch Minting', function () {
    const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]

    /**
     * The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedBatchByAdmin', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(0n)
      }

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(this.admin)
        .mintBatch(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)

      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(
          TOKEN_SUPPLY_BY_HOLDERS[i]
        )
      }

      expect(await this.cmtat.totalSupply()).to.equal(
        TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => {
          return a + b
        })
      )
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'Transfer')
          .withArgs(ZERO_ADDRESS, TOKEN_HOLDER[i], TOKEN_SUPPLY_BY_HOLDERS[i])
      }
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        await expect(this.logs)
          .to.emit(this.cmtat, 'Mint')
          .withArgs(TOKEN_HOLDER[i], TOKEN_SUPPLY_BY_HOLDERS[i])
      }
    })

    it('testCanBeMinteBatchdByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address1)
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]

      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(0n)
      }

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(this.address1)
        .mintBatch(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)

      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(
          TOKEN_SUPPLY_BY_HOLDERS[i]
        )
      }

      expect(await this.cmtat.totalSupply()).to.equal(
        TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => {
          return a + b
        })
      )
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'Transfer')
          .withArgs(ZERO_ADDRESS, TOKEN_HOLDER[i], TOKEN_SUPPLY_BY_HOLDERS[i])
      }
      // emits a Mint event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'Mint')
          .withArgs(TOKEN_HOLDER[i], TOKEN_SUPPLY_BY_HOLDERS[i])
      }
    })

    it('testCannotMintBatchByNonMinter', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.address1)
          .mintBatch(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, MINTER_ROLE)
    })

    it('testCannotMintBatchIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_HOLDER_INVALID = [this.admin, this.address1]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.admin)
          .mintBatch(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotMintBatchIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const TOKEN_HOLDER_INVALID = [
        this.admin,
        this.address1,
        this.address1,
        this.address1
      ]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.admin)
          .mintBatch(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotMintBatchIfTOSIsEmpty', async function () {
      const TOKEN_HOLDER_INVALID = []
      const TOKEN_SUPPLY_BY_HOLDERS = []
      await expect(
        this.cmtat
          .connect(this.admin)
          .mintBatch(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_EmptyAccounts'
      )
    })
  })
}
module.exports = ERC20MintModuleCommon
