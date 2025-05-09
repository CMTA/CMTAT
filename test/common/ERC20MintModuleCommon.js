const { expect } = require('chai')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../utils.js')
const VALUE1 = 20n
const VALUE2 = 50n
function ERC20MintModuleCommon () {
  
  context('Minting', function () {
    async function testMint(sender) {
      // Arrange
  
        // Arrange - Assert
        // Check first balance
        expect(await this.cmtat.balanceOf(this.address1)).to.equal(0n)
  
        // Act
        // Issue 20 and check balances and total supply
        this.logs = await this.cmtat
          .connect(sender)
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
          .withArgs(this.address1, VALUE1, "0x")
  
        // Act
        // Issue 50 and check intermediate balances and total supply
        this.logs = await this.cmtat
          .connect(sender)
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
          .withArgs(this.address2, VALUE2, "0x")
    }

    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      const bindTest = testMint.bind(this)
      await bindTest(this.admin)
    })

    it('testCanMintByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address1)
      
        const bindTest = testMint.bind(this)
        await bindTest(this.address1)
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

    it('testCanBeMintedEvenIfContractIsPaused', async function () {
      await this.cmtat
      .connect(this.admin)
      .pause()
      const bindTest = testMint.bind(this)
      await bindTest(this.admin)
    })

    it('testCannotBeMintedIfContractIsDeactivated', async function () {
      await this.cmtat
      .connect(this.admin)
      .deactivateContract()
      await expect(
        this.cmtat.connect(this.admin).mint(this.address1, VALUE1)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'CMTAT_InvalidMint'
        )
    })

    it('testCannotBeMintedIfToIsFrozen', async function () {
      await this.cmtat
      .connect(this.admin)
      .setAddressFrozen(this.address1, true);
      await expect(
        this.cmtat.connect(this.admin).mint(this.address1, VALUE1)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'CMTAT_InvalidMint'
        )
    })
  })

  context('Batch Minting', function () {
    const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
    async function testMintBatch(sender){
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(0n)
      }

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(sender)
        .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)

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
        await expect(this.logs)
          .to.emit(this.cmtat, 'BatchMint')
          .withArgs(sender, TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      

    }
    /**
     * The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedBatchByAdmin', async function () {
      const bindTest = testMintBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testCanBeMintBatchdByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address1)
      const bindTest = testMintBatch.bind(this)
      await bindTest(this.address1)
    })

    it('testCanBeMintedBatchEvenIfContractIsPaused', async function () {
      await this.cmtat
      .connect(this.admin)
      .pause()
      const bindTest = testMintBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testCannotBatchMintByNonMinter', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.address1)
          .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, MINTER_ROLE)
    })

    it('testCannotBatchMintIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_HOLDER_INVALID = [this.admin, this.address1]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotBatchMintIfLengthMismatchTooManyAddresses', async function () {
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
          .batchMint(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotbatchMintIfTOSIsEmpty', async function () {
      const TOKEN_HOLDER_INVALID = []
      const TOKEN_SUPPLY_BY_HOLDERS = []
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_EmptyAccounts'
      )
    })
  })
  context('batchTransfer', function () {
    const TOKEN_AMOUNTS = [10n, 100n, 1000n]

    beforeEach(async function () {
      // Only the admin has tokens
      await this.cmtat.connect(this.admin).mint(
        this.admin,
        TOKEN_AMOUNTS.reduce((a, b) => {
          return a + b
        })
      )
    })

    it('testbatchTransfer', async function () {
      const TOKEN_ADDRESS_TOS = [this.address1, this.address2, this.address3]
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .batchTransfer(TOKEN_ADDRESS_TOS, TOKEN_AMOUNTS)
      // Assert
      for (let i = 0; i < TOKEN_ADDRESS_TOS.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_ADDRESS_TOS[i])).to.equal(
          TOKEN_AMOUNTS[i]
        )
      }
      // emits a Transfer event
      for (let i = 0; i < TOKEN_ADDRESS_TOS.length; ++i) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'Transfer')
          .withArgs(this.admin, TOKEN_ADDRESS_TOS[i], TOKEN_AMOUNTS[i])
      }
    })

    // ADDRESS1 -> ADDRESS2
    it('testCannotbatchTransferMoreTokensThanOwn', async function () {
      const TOKEN_ADDRESS_TOS = [this.address1, this.address2, this.address3]
      const BALANCE_AFTER_FIRST_TRANSFER =
        (await this.cmtat.balanceOf(this.admin)) - TOKEN_AMOUNTS[0]
      const AMOUNT_TO_TRANSFER_SECOND = BALANCE_AFTER_FIRST_TRANSFER + 1n
      // Second amount is invalid
      const TOKEN_AMOUNTS_INVALID = [
        TOKEN_AMOUNTS[0],
        AMOUNT_TO_TRANSFER_SECOND,
        TOKEN_AMOUNTS[2]
      ]
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS, TOKEN_AMOUNTS_INVALID)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(
          this.admin.address,
          BALANCE_AFTER_FIRST_TRANSFER,
          AMOUNT_TO_TRANSFER_SECOND
        )
    })

    it('testCannotbatchTransferIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_ADDRESS_TOS_INVALID = [this.address1, this.address2]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS_INVALID, TOKEN_AMOUNTS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_TosValueslengthMismatch'
      )
    })

    it('testCannotbatchTransferIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const TOKEN_ADDRESS_TOS_INVALID = [
        this.address1,
        this.address2,
        this.address1,
        this.address1
      ]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS_INVALID, TOKEN_AMOUNTS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_TosValueslengthMismatch'
      )
    })

    it('testCannotbatchTransferIfTOSIsEmpty', async function () {
      const TOKEN_ADDRESS_TOS_INVALID = []
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS_INVALID, TOKEN_AMOUNTS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_EmptyTos'
      )
    })
  })
}
module.exports = ERC20MintModuleCommon
