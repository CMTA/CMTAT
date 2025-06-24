const {
  BURNER_ROLE,
  BURNER_FROM_ROLE,
  MINTER_ROLE,
  ZERO_ADDRESS
} = require('../utils')
const { expect } = require('chai')
// const REASON = 'BURN_TEST'
const REASON_STRING = 'BURN_TEST'
const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON = ethers.Typed.bytes(REASON_EVENT)
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))
function ERC20BurnModuleCommon () {
  context('burn', function () {
    const INITIAL_SUPPLY = 50n
    const INITIAL_SUPPLY_TYPED = ethers.Typed.uint256(50)
    const VALUE1 = 20n
    const VALUE_TYPED = ethers.Typed.uint256(20)
    const DIFFERENCE = INITIAL_SUPPLY - VALUE1
    const DIFFERENCE_TYPED = ethers.Typed.uint256(30)
    async function testBurn (sender) {
      // Act
      // Burn 20
      this.logs = await this.cmtat
        .connect(sender)
        .burn(this.address1, VALUE1, REASON)
      // Assert
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, VALUE1)
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Burn')
        .withArgs(sender, this.address1, VALUE1, REASON_EVENT)
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(DIFFERENCE)
      expect(await this.cmtat.totalSupply()).to.equal(DIFFERENCE)

      // Burn 30
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .burn(this.address1, DIFFERENCE, REASON)

      // Assert
      // Emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, DIFFERENCE)
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Burn')
        .withArgs(sender, this.address1, DIFFERENCE, REASON_EVENT)
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(0)
      expect(await this.cmtat.totalSupply()).to.equal(0)
    }

    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY)
      expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
    })

    it('testCanBeBurntByAdmin', async function () {
      const bindTest = testBurn.bind(this)
      await bindTest(this.admin)
    })

    it('testCanBeBurntByAdminWithoutReason', async function () {
      // Act
      // Burn 20
      this.logs = await this.cmtat
        .connect(this.admin)
        .burn(this.address1, VALUE_TYPED)
      // Assert
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, VALUE1)
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Burn')
        .withArgs(this.admin, this.address1, VALUE1, '0x')
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(DIFFERENCE)
      expect(await this.cmtat.totalSupply()).to.equal(DIFFERENCE)

      // Burn 30
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .burn(this.address1, DIFFERENCE_TYPED)

      // Assert
      // Emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, DIFFERENCE)
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Burn')
        .withArgs(this.admin, this.address1, DIFFERENCE, '0x')
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(0n)
      expect(await this.cmtat.totalSupply()).to.equal(0n)
    })

    it('testCanBeBurntByBurnerRole', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_ROLE, this.address2)
      // Act
      const bindTest = testBurn.bind(this)
      await bindTest(this.address2)
    })

    it('testCannotBeBurntIfBalanceExceeds', async function () {
      // error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
      const AMOUNT_TO_BURN = 200n
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(this.address1)
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .burn(this.address1, AMOUNT_TO_BURN, REASON_EMPTY)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(this.address1.address, ADDRESS1_BALANCE, AMOUNT_TO_BURN)
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      await expect(
        this.cmtat.connect(this.address2).burn(this.address1, 20n, REASON_EMPTY)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, BURNER_ROLE)

      // Without reason
      await expect(
        this.cmtat.connect(this.address2).burn(this.address1, 20n, REASON_EMPTY)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, BURNER_ROLE)
    })

    it('testCannotBeBurnIfContractIsDeactivated', async function () {
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      await expect(
        this.cmtat.connect(this.admin).burn(this.address1, VALUE_TYPED)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.address1, ZERO_ADDRESS, VALUE1)
    })

    it('testCanBeBurnEvenIfContractIsPaused', async function () {
      await this.cmtat.connect(this.admin).pause()
      const bindTest = testBurn.bind(this)
      await bindTest(this.admin)
    })

    it('testCannotBeBurnIfAddressIsFrozen', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)

      // Act
      const VALUE = 20
      const VALUE_TYPED = ethers.Typed.uint256(20)
      await expect(
        this.cmtat.connect(this.admin).burn(this.address1, VALUE_TYPED)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.address1.address, ZERO_ADDRESS, VALUE)
    })
  })

  context('burnAndMint', function () {
    const INITIAL_SUPPLY = 50n
    const VALUE1 = 20n
    const REASON_STRING_LOCAL = 'recovery'
    const REASON_EVENT_LOCAL = ethers.toUtf8Bytes(REASON_STRING_LOCAL)
    const REASON = ethers.Typed.bytes(REASON_EVENT_LOCAL)
    const AMOUNT_TO_BURN = 20n
    const AMOUNT_TO_MINT = 15n
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY)
      expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
    })

    it('testCanBurnAndMint', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_ROLE, this.address2)
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address2)
      // Act
      this.logs = await this.cmtat
        .connect(this.address2)
        .burnAndMint(
          this.address1,
          this.address3,
          AMOUNT_TO_BURN,
          AMOUNT_TO_MINT,
          REASON
        )
      // Assert
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_BURN)

      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address3, AMOUNT_TO_MINT)

      await expect(this.logs)
        .to.emit(this.cmtat, 'Burn')
        .withArgs(
          this.address2,
          this.address1,
          AMOUNT_TO_BURN,
          REASON_EVENT_LOCAL
        )

      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(
          this.address2,
          this.address3,
          AMOUNT_TO_MINT,
          REASON_EVENT_LOCAL
        )

      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        INITIAL_SUPPLY - AMOUNT_TO_BURN
      )
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        AMOUNT_TO_MINT
      )
      expect(await this.cmtat.totalSupply()).to.equal(
        INITIAL_SUPPLY - AMOUNT_TO_BURN + AMOUNT_TO_MINT
      )
    })

    it('testCannotBurnAndMintWithoutMinterRole', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_ROLE, this.address2)
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .burnAndMint(
            this.address1,
            this.address3,
            AMOUNT_TO_BURN,
            AMOUNT_TO_MINT,
            REASON
          )
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, MINTER_ROLE)
    })

    it('testCannotBurnAndMintWithoutBurnerRole', async function () {
      // Arrange

      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address2)
      // Assert
      await expect(
        this.cmtat
          .connect(this.address2)
          .burnAndMint(
            this.address1,
            this.address3,
            AMOUNT_TO_BURN,
            AMOUNT_TO_MINT,
            REASON
          )
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, BURNER_ROLE)
    })

    it('testCannotBeBurnAndMintIfContractIsDeactivated', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      await this.cmtat.connect(this.address1).approve(this.admin, 50n)
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .burnAndMint(
            this.address1,
            this.address3,
            AMOUNT_TO_BURN,
            AMOUNT_TO_MINT,
            REASON
          )
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_BURN)
    })

    it('testCanBeBurnAndMintEvenIFContractIsPaused', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat
        .connect(this.admin)
        .burnAndMint(
          this.address1,
          this.address3,
          AMOUNT_TO_BURN,
          AMOUNT_TO_MINT,
          REASON
        )
    })
  })

  context('batchBurn', function () {
    const TOKEN_SUPPLY_BY_HOLDERS = [10, 100, 1000]
    const INITIAL_SUPPLY = TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => {
      return a + b
    })
    const TOKEN_BY_HOLDERS_TO_BURN = [5, 50, 500]
    const TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN = [
      TOKEN_SUPPLY_BY_HOLDERS[0] - TOKEN_BY_HOLDERS_TO_BURN[0],
      TOKEN_SUPPLY_BY_HOLDERS[1] - TOKEN_BY_HOLDERS_TO_BURN[1],
      TOKEN_SUPPLY_BY_HOLDERS[2] - TOKEN_BY_HOLDERS_TO_BURN[2]
    ]
    const TOTAL_SUPPLY_AFTER_BURN =
      INITIAL_SUPPLY -
      TOKEN_BY_HOLDERS_TO_BURN.reduce((a, b) => {
        return a + b
      })

    async function testBatchBurn (sender) {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Act
      // Burn
      this.logs = await this.cmtat
        .connect(sender)
        .batchBurn(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, REASON)
      // Assert
      // emits a Transfer event
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Transfer event
        await expect(this.logs)
          .to.emit(this.cmtat, 'Transfer')
          .withArgs(TOKEN_HOLDER[i], ZERO_ADDRESS, TOKEN_BY_HOLDERS_TO_BURN[i])
      }
      // emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'BatchBurn')
        .withArgs(sender, TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, REASON_EVENT)
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(
          TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i]
        )
      }

      expect(await this.cmtat.totalSupply()).to.equal(TOTAL_SUPPLY_AFTER_BURN)
    }

    async function testBatchBurnWithoutReason (sender) {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Act
      // Burn
      this.logs = await this.cmtat
        .connect(sender)
        .batchBurn(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN)
      // Assert
      // emits a Transfer event
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Transfer event
        await expect(this.logs)
          .to.emit(this.cmtat, 'Transfer')
          .withArgs(TOKEN_HOLDER[i], ZERO_ADDRESS, TOKEN_BY_HOLDERS_TO_BURN[i])
      }
      // emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'BatchBurn')
        .withArgs(sender, TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, '0x')
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(
          TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i]
        )
      }

      expect(await this.cmtat.totalSupply()).to.equal(TOTAL_SUPPLY_AFTER_BURN)
    }

    beforeEach(async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2];
      ({ logs: this.logs1 } = await this.cmtat
        .connect(this.admin)
        .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS))
      expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
    })

    it('testCanBeBurntBatchByAdmin', async function () {
      const bindTest = testBatchBurn.bind(this)
      await bindTest(this.admin)
    })

    it('testCanBeBurntBatchByAdminWithoutReason', async function () {
      const bindTest = testBatchBurnWithoutReason.bind(this)
      await bindTest(this.admin)
    })

    it('testCanBeBurntBatchByBurnerRoleWithoutReason', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_ROLE, this.address2)

      // Act
      const bindTest = testBatchBurnWithoutReason.bind(this)
      await bindTest(this.address2)
    })

    it('testCanBeBurntBatchByBurnerRole', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_ROLE, this.address2)

      // Act
      const bindTest = testBatchBurn.bind(this)
      await bindTest(this.address2)
    })

    it('testCannotBeBurntBatchIfOneBalanceExceeds', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_BY_HOLDERS_TO_BURN_FAIL = [5n, 50n, 5000000n]
      const ADDRESS2_BALANCE = await this.cmtat.balanceOf(this.address2)
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchBurn(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN_FAIL, REASON_EMPTY)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(
          this.address2.address,
          ADDRESS2_BALANCE,
          TOKEN_BY_HOLDERS_TO_BURN_FAIL[2]
        )
    })

    it('testCannotBeBurntBatchWithoutBurnerRole', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      await expect(
        this.cmtat
          .connect(this.address2)
          .batchBurn(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, REASON_EMPTY)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, BURNER_ROLE)
    })

    it('testCannotBatchBurnIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_HOLDER_INVALID = [this.admin, this.address1]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchBurn(
            TOKEN_HOLDER_INVALID,
            TOKEN_BY_HOLDERS_TO_BURN,
            REASON_EMPTY
          )
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_BurnModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotBatchBurnIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const TOKEN_HOLDER_INVALID = [
        this.admin,
        this.address1,
        this.address1,
        this.address1
      ]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchBurn(
            TOKEN_HOLDER_INVALID,
            TOKEN_BY_HOLDERS_TO_BURN,
            REASON_EMPTY
          )
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_BurnModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotBatchBurnIfAccountsIsEmpty', async function () {
      const TOKEN_ADDRESS_TOS_INVALID = []
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchBurn(
            TOKEN_ADDRESS_TOS_INVALID,
            TOKEN_BY_HOLDERS_TO_BURN,
            REASON
          )
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_BurnModule_EmptyAccounts'
      )
    })
  })
}
module.exports = ERC20BurnModuleCommon
