const {
  BURNER_ROLE,
  BURNER_FROM_ROLE,
  MINTER_ROLE,
  ZERO_ADDRESS
} = require('../utils')
const { expect } = require('chai');

function ERC20BurnModuleCommon () {
  context('burn', function () {
    const INITIAL_SUPPLY = 50
    const REASON = 'BURN_TEST'
    const VALUE1 = 20
    const DIFFERENCE = INITIAL_SUPPLY - VALUE1

    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY);
      expect(await this.cmtat.totalSupply()).to.equal(
        INITIAL_SUPPLY
      )
    })

    it('testCanBeBurntByAdmin', async function () {
      // Act
      // Burn 20
      this.logs = await this.cmtat.connect(this.admin).burn(this.address1, VALUE1, REASON)
      // Assert
      // emits a Transfer event
      await expect(this.logs).to.emit(this.cmtat, 'Transfer').withArgs( this.address1, ZERO_ADDRESS, VALUE1);
      // Emits a Burn event
      await expect(this.logs).to.emit(this.cmtat, 'Burn').withArgs( this.address1, VALUE1, REASON);
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        DIFFERENCE
      );
      expect(await this.cmtat.totalSupply()).to.equal(DIFFERENCE)

      // Burn 30
      // Act
      this.logs = await this.cmtat.connect(this.admin).burn(this.address1, DIFFERENCE, REASON)

      // Assert
      // Emits a Transfer event
      await expect(this.logs).to.emit(this.cmtat, 'Transfer').withArgs( this.address1, ZERO_ADDRESS, DIFFERENCE);
      // Emits a Burn event
      await expect(this.logs).to.emit(this.cmtat, 'Burn').withArgs(
        this.address1,
        DIFFERENCE,
        REASON);
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(0n);
      expect(await this.cmtat.totalSupply()).to.equal(0n)
    })

    it('testCanBeBurntByBurnerRole', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).grantRole(BURNER_ROLE, this.address2)
      // Act
      this.logs = await this.cmtat.connect(this.address2).burn(this.address1, VALUE1, REASON);
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        DIFFERENCE
      );
      expect(await this.cmtat.totalSupply()).to.equal(DIFFERENCE)

      // Emits a Transfer event
      await expect(this.logs).to.emit(this.cmtat, 'Transfer').withArgs( this.address1, ZERO_ADDRESS, VALUE1);
      // Emits a Burn event
      await expect(this.logs).to.emit(this.cmtat, 'Burn').withArgs( this.address1, VALUE1, REASON);
    })

    it('testCannotBeBurntIfBalanceExceeds', async function () {
      // error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
      const AMOUNT_TO_BURN = 200n
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(this.address1)
      // Act
      await expect(  this.cmtat.connect(this.admin).burn(this.address1, AMOUNT_TO_BURN, ''))
      .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
      .withArgs(this.address1.address, ADDRESS1_BALANCE, AMOUNT_TO_BURN);
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      await expect( this.cmtat.connect(this.address2).burn(this.address1, 20n, ''))
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address2.address, BURNER_ROLE);
    })
  })

  context('burnFrom', function () {
    const INITIAL_SUPPLY = 50n
    const VALUE1 = 20n

    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY);
      expect(await this.cmtat.totalSupply()).to.equal(
        INITIAL_SUPPLY
      )
    })

    it('canBeBurnFrom', async function () {
      // Arrange
      const AMOUNT_TO_BURN = 20n
      await this.cmtat.connect(this.admin).grantRole(BURNER_FROM_ROLE, this.address2)
      await this.cmtat.connect(this.address1).approve(this.address2, 50n)
      // Act
      this.logs = await this.cmtat.connect(this.address2).burnFrom(this.address1, AMOUNT_TO_BURN)
      // Assert
      await expect(this.logs)
      .to.emit(this.cmtat, "Transfer")
      .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_BURN);
      await expect(this.logs)
      .to.emit(this.cmtat, "BurnFrom")
      .withArgs(this.address1, this.address2, AMOUNT_TO_BURN);
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(30n);
      expect(await this.cmtat.totalSupply()).to.equal(30n)
    })

    it('TestCannotBeBurnWithoutAllowance', async function () {
      const AMOUNT_TO_BURN = 20n
      await expect(  this.cmtat.connect(this.admin).burnFrom(this.address1, AMOUNT_TO_BURN))
      .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientAllowance')
      .withArgs(this.admin.address, 0, AMOUNT_TO_BURN);
    })

    it('testCannotBeBurntWithoutBurnerFromRole', async function () {
      await expect(  this.cmtat.connect(this.address2).burnFrom(this.address1, 20n))
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address2.address, BURNER_FROM_ROLE);
    })
  })

  context('burnAndMint', function () {
    const INITIAL_SUPPLY = 50n
    const VALUE1 = 20n

    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY);
      expect(await this.cmtat.totalSupply()).to.equal(
        INITIAL_SUPPLY
      )
    })

    it('canBeBurnAndMit', async function () {
      // Arrange
      const AMOUNT_TO_BURN = 20n
      const AMOUNT_TO_MINT = 15n
      await this.cmtat.connect(this.admin).grantRole(BURNER_ROLE, this.address2)
      await this.cmtat.connect(this.admin).grantRole(MINTER_ROLE, this.address2)
      // Act
      this.logs = await this.cmtat.connect(this.address2).burnAndMint(
        this.address1,
        this.address3,
        AMOUNT_TO_BURN,
        AMOUNT_TO_MINT,
        'recovery'
      )
      // Assert
      await expect(this.logs)
      .to.emit(this.cmtat, "Transfer")
      .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_BURN);

      await expect(this.logs)
      .to.emit(this.cmtat, "Transfer")
      .withArgs(ZERO_ADDRESS,this.address3,AMOUNT_TO_MINT);

      await expect(this.logs)
      .to.emit(this.cmtat, "Burn")
      .withArgs(this.address1, AMOUNT_TO_BURN, 'recovery');

      await expect(this.logs)
      .to.emit(this.cmtat, "Mint")
      .withArgs(this.address3, AMOUNT_TO_MINT);

      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        INITIAL_SUPPLY - AMOUNT_TO_BURN
      );
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        AMOUNT_TO_MINT
      );
      expect(await this.cmtat.totalSupply()).to.equal(
        INITIAL_SUPPLY - AMOUNT_TO_BURN + AMOUNT_TO_MINT
      )
    })

    it('canBeBurnAndMintWithoutMinterRole', async function () {
      // Arrange
      const AMOUNT_TO_BURN = 20n
      const AMOUNT_TO_MINT = 15n
      await this.cmtat.connect(this.admin).grantRole(BURNER_ROLE, this.address2)
      // Act
      await expect( this.cmtat.connect(this.address2).burnAndMint(
        this.address1,
        this.address3,
        AMOUNT_TO_BURN,
        AMOUNT_TO_MINT,
        'recovery'
      ))
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address2.address, MINTER_ROLE);
    })

    it('canBeBurnAndMintWithoutBurnerRole', async function () {
      // Arrange
      const AMOUNT_TO_BURN = 20n
      const AMOUNT_TO_MINT = 15n
      await this.cmtat.connect(this.admin).grantRole(MINTER_ROLE, this.address2)
      // Assert
      await expect( this.cmtat.connect(this.address2).burnAndMint(
        this.address1,
        this.address3,
        AMOUNT_TO_BURN,
        AMOUNT_TO_MINT,
        'recovery'
      ))
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address2.address, BURNER_ROLE);
    })
  })

  context('burnBatch', function () {
    const REASON = 'BURN_TEST'
    const TOKEN_SUPPLY_BY_HOLDERS = [10, 100, 1000]
    const INITIAL_SUPPLY = TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => {
      return a + b
    })
    const TOKEN_BY_HOLDERS_TO_BURN = [5, 50, 500]
    const TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN = [
      TOKEN_SUPPLY_BY_HOLDERS[0] - (TOKEN_BY_HOLDERS_TO_BURN[0]),
      TOKEN_SUPPLY_BY_HOLDERS[1] - (TOKEN_BY_HOLDERS_TO_BURN[1]),
      TOKEN_SUPPLY_BY_HOLDERS[2] - (TOKEN_BY_HOLDERS_TO_BURN[2])
    ]
    const TOTAL_SUPPLY_AFTER_BURN = INITIAL_SUPPLY  - (
      TOKEN_BY_HOLDERS_TO_BURN.reduce((a, b) => {
        return a + b
      })
    )

    beforeEach(async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2];
      ({ logs: this.logs1 } = await this.cmtat.connect(this.admin).mintBatch(
        TOKEN_HOLDER,
        TOKEN_SUPPLY_BY_HOLDERS
      ));
      expect(await this.cmtat.totalSupply()).to.equal(
        INITIAL_SUPPLY
      )
    })

    it('testCanBeBurntBatchByAdmin', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Act
      // Burn
      this.logs = await this.cmtat.connect(this.admin).burnBatch(
        TOKEN_HOLDER,
        TOKEN_BY_HOLDERS_TO_BURN,
        REASON,
      )
      // Assert
      // emits a Transfer event
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Transfer event
        await expect(this.logs)
        .to.emit(this.cmtat, "Transfer")
        .withArgs(TOKEN_HOLDER[i], ZERO_ADDRESS, TOKEN_BY_HOLDERS_TO_BURN[i]);
      }

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Burn event
        await expect(this.logs)
        .to.emit(this.cmtat, "Burn")
        .withArgs(TOKEN_HOLDER[i], TOKEN_BY_HOLDERS_TO_BURN[i], REASON);
      }
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(
          TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i]
        )
      }

      expect(await this.cmtat.totalSupply()).to.equal(
        TOTAL_SUPPLY_AFTER_BURN
      )
    })

    it('testCanBeBurntBatchByBurnerRole', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Arrange
      await this.cmtat.connect(this.admin).grantRole(BURNER_ROLE, this.address2)

      // Act
      // Burn
      this.logs = await this.cmtat.connect(this.address2).burnBatch(
        TOKEN_HOLDER,
        TOKEN_BY_HOLDERS_TO_BURN,
        REASON
      )

      // Assert
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a  transfer  event
        await expect(this.logs)
        .to.emit(this.cmtat, "Transfer")
        .withArgs(TOKEN_HOLDER[i], ZERO_ADDRESS, TOKEN_BY_HOLDERS_TO_BURN[i]);
    }; 

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a burn  

        await expect(this.logs)
        .to.emit(this.cmtat, "Burn")
        .withArgs(TOKEN_HOLDER[i], TOKEN_BY_HOLDERS_TO_BURN[i],  REASON);
      }
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(
          TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i]
        )
      }

      expect(await this.cmtat.totalSupply()).to.equal(
        TOTAL_SUPPLY_AFTER_BURN
      )
    })

    it('testCannotBeBurntBatchIfOneBalanceExceeds', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_BY_HOLDERS_TO_BURN_FAIL = [5n, 50n, 5000000n]
      const ADDRESS2_BALANCE = await this.cmtat.balanceOf(this.address2)
      // Act
      await expect(  this.cmtat.connect(this.admin).burnBatch(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN_FAIL, ''))
      .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
      .withArgs(this.address2.address, ADDRESS2_BALANCE, TOKEN_BY_HOLDERS_TO_BURN_FAIL[2]);
    })

    it('testCannotBeBurntBatchWithoutBurnerRole', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      await expect( this.cmtat.connect(this.address2).burnBatch(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, ''))
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address2.address, BURNER_ROLE);
    })

    it('testCannotburnBatchIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_HOLDER_INVALID = [this.admin, this.address1]
      await expect(this.cmtat.connect(this.admin).burnBatch(
        TOKEN_HOLDER_INVALID,
        TOKEN_BY_HOLDERS_TO_BURN,
        REASON
      ))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_BurnModule_AccountsValueslengthMismatch')
    })

    it('testCannotburnBatchIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const TOKEN_HOLDER_INVALID = [this.admin, this.address1, this.address1, this.address1]
      await expect(this.cmtat.connect(this.admin).burnBatch(
        TOKEN_HOLDER_INVALID,
        TOKEN_BY_HOLDERS_TO_BURN,
        REASON
      ))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_BurnModule_AccountsValueslengthMismatch')
    })

    it('testCannotburnBatchIfAccountsIsEmpty', async function () {
      const TOKEN_ADDRESS_TOS_INVALID = []
      await expect(this.cmtat.connect(this.admin).burnBatch(
        TOKEN_ADDRESS_TOS_INVALID,
        TOKEN_BY_HOLDERS_TO_BURN,
        REASON
      ))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_BurnModule_EmptyAccounts')
    })
  })
}
module.exports = ERC20BurnModuleCommon
