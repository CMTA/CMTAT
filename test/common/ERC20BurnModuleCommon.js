const { BN, expectEvent } = require('@openzeppelin/test-helpers')
const { BURNER_ROLE, BURNER_FROM_ROLE, MINTER_ROLE, ZERO_ADDRESS } = require('../utils')
const {
  expectRevertCustomError
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { should } = require('chai').should()

function ERC20BurnModuleCommon (admin, address1, address2, address3) {
  context('burn', function () {
    const INITIAL_SUPPLY = new BN(50)
    const REASON = 'BURN_TEST'
    const VALUE1 = new BN(20)
    const DIFFERENCE = INITIAL_SUPPLY.sub(VALUE1)

    beforeEach(async function () {
      await this.cmtat.mint(address1, INITIAL_SUPPLY, { from: admin });
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(
        INITIAL_SUPPLY
      )
    })

    it('testCanBeBurntByAdmin', async function () {
      // Act
      // Burn 20
      this.logs = await this.cmtat.burn(address1, VALUE1, REASON, {
        from: admin
      })
      // Assert
      // emits a Transfer event
      expectEvent(this.logs, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: VALUE1
      })
      // Emits a Burn event
      expectEvent(this.logs, 'Burn', {
        owner: address1,
        value: VALUE1,
        reason: REASON
      });
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(
        DIFFERENCE
      );
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(DIFFERENCE)

      // Burn 30
      // Act
      this.logs = await this.cmtat.burn(address1, DIFFERENCE, REASON, {
        from: admin
      })

      // Assert
      // Emits a Transfer event
      expectEvent(this.logs, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: DIFFERENCE
      })
      // Emits a Burn event
      expectEvent(this.logs, 'Burn', {
        owner: address1,
        value: DIFFERENCE,
        reason: REASON
      });
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(BN(0));
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(BN(0))
    })

    it('testCanBeBurntByBurnerRole', async function () {
      // Arrange
      await this.cmtat.grantRole(BURNER_ROLE, address2, { from: admin })
      // Act
      this.logs = await this.cmtat.burn(address1, VALUE1, REASON, {
        from: address2
      });
      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(
        DIFFERENCE
      );
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(DIFFERENCE)

      // Emits a Transfer event
      expectEvent(this.logs, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: VALUE1
      })

      // Emits a Burn event
      expectEvent(this.logs, 'Burn', {
        owner: address1,
        value: VALUE1,
        reason: REASON
      })
    })

    it('testCannotBeBurntIfBalanceExceeds', async function () {
      // error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
      const AMOUNT_TO_BURN = BN(200)
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(address1)
      // Act
      await expectRevertCustomError(
        this.cmtat.burn(address1, AMOUNT_TO_BURN, '', { from: admin }),
        'ERC20InsufficientBalance',
        [address1, ADDRESS1_BALANCE, AMOUNT_TO_BURN]
      )
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      await expectRevertCustomError(
        this.cmtat.burn(address1, 20, '', { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, BURNER_ROLE]
      )
    })
  })

  context('burnFrom', function () {
    const INITIAL_SUPPLY = new BN(50)
    const VALUE1 = new BN(20)

    beforeEach(async function () {
      await this.cmtat.mint(address1, INITIAL_SUPPLY, { from: admin });
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(
        INITIAL_SUPPLY
      )
    })

    it('canBeBurnFrom', async function () {
      // Arrange
      const AMOUNT_TO_BURN = BN(20)
      await this.cmtat.grantRole(BURNER_FROM_ROLE, address2, { from: admin })
      await this.cmtat.approve(address2, 50, { from: address1 })
      // Act
      this.logs = await this.cmtat.burnFrom(address1, AMOUNT_TO_BURN, { from: address2 })
      // Assert
      expectEvent(this.logs, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: AMOUNT_TO_BURN
      })
      expectEvent(this.logs, 'BurnFrom', {
        owner: address1,
        spender: address2,
        value: AMOUNT_TO_BURN
      });
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('30');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('30')
    })

    it('TestCannotBeBurnWithoutAllowance', async function () {
      const AMOUNT_TO_BURN = 20
      await expectRevertCustomError(
        this.cmtat.burnFrom(address1, AMOUNT_TO_BURN, { from: admin }),
        'ERC20InsufficientAllowance',
        [admin, 0, AMOUNT_TO_BURN])
    })

    it('testCannotBeBurntWithoutBurnerFromRole', async function () {
      await expectRevertCustomError(
        this.cmtat.burnFrom(address1, 20, { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, BURNER_FROM_ROLE])
    })
  })

  context('burnAndMint', function () {
    const INITIAL_SUPPLY = new BN(50)
    const VALUE1 = new BN(20)

    beforeEach(async function () {
      await this.cmtat.mint(address1, INITIAL_SUPPLY, { from: admin });
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(
        INITIAL_SUPPLY
      )
    })

    it('canBeBurnAndMit', async function () {
      // Arrange
      const AMOUNT_TO_BURN = BN(20)
      const AMOUNT_TO_MINT = BN(15)
      await this.cmtat.grantRole(BURNER_ROLE, address2, { from: admin })
      await this.cmtat.grantRole(MINTER_ROLE, address2, { from: admin })
      // await this.cmtat.approve(address2, 50, { from: address1 })
      // Act
      this.logs = await this.cmtat.burnAndMint(address1, address3, AMOUNT_TO_BURN, AMOUNT_TO_MINT, 'recovery', { from: address2 })
      // Assert
      expectEvent(this.logs, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: AMOUNT_TO_BURN
      })
      expectEvent(this.logs, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address3,
        value: AMOUNT_TO_MINT
      })

      expectEvent(this.logs, 'Burn', {
        owner: address1,
        value: AMOUNT_TO_BURN,
        reason: 'recovery'
      })

      expectEvent(this.logs, 'Mint', {
        account: address3,
        value: AMOUNT_TO_MINT
      });
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(INITIAL_SUPPLY.sub(AMOUNT_TO_BURN));
      (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal(AMOUNT_TO_MINT);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(INITIAL_SUPPLY.sub(AMOUNT_TO_BURN).add(AMOUNT_TO_MINT))
    })

    it('canBeBurnAndMintWithoutMinterRole', async function () {
      // Arrange
      const AMOUNT_TO_BURN = BN(20)
      const AMOUNT_TO_MINT = BN(15)
      await this.cmtat.grantRole(BURNER_ROLE, address2, { from: admin })
      // await this.cmtat.approve(address2, 50, { from: address1 })
      // Act
      await expectRevertCustomError(
        this.cmtat.burnAndMint(address1, address3, AMOUNT_TO_BURN, AMOUNT_TO_MINT, 'recovery', { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, MINTER_ROLE])
    })

    it('canBeBurnAndMintWithoutBurnerRole', async function () {
      // Arrange
      const AMOUNT_TO_BURN = BN(20)
      const AMOUNT_TO_MINT = BN(15)
      await this.cmtat.grantRole(MINTER_ROLE, address2, { from: admin })
      // await this.cmtat.approve(address2, 50, { from: address1 })
      // Assert
      await expectRevertCustomError(
        this.cmtat.burnAndMint(address1, address3, AMOUNT_TO_BURN, AMOUNT_TO_MINT, 'recovery', { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, BURNER_ROLE])
    })
  })

  context('burnBatch', function () {
    const REASON = 'BURN_TEST'
    const TOKEN_HOLDER = [admin, address1, address2]
    const TOKEN_SUPPLY_BY_HOLDERS = [BN(10), BN(100), BN(1000)]
    const INITIAL_SUPPLY = TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => {
      return a.add(b)
    })
    const TOKEN_BY_HOLDERS_TO_BURN = [BN(5), BN(50), BN(500)]
    const TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN = [
      TOKEN_SUPPLY_BY_HOLDERS[0].sub(TOKEN_BY_HOLDERS_TO_BURN[0]),
      TOKEN_SUPPLY_BY_HOLDERS[1].sub(TOKEN_BY_HOLDERS_TO_BURN[1]),
      TOKEN_SUPPLY_BY_HOLDERS[2].sub(TOKEN_BY_HOLDERS_TO_BURN[2])
    ]
    const TOTAL_SUPPLY_AFTER_BURN = INITIAL_SUPPLY.sub(
      TOKEN_BY_HOLDERS_TO_BURN.reduce((a, b) => {
        return a.add(b)
      })
    )

    beforeEach(async function () {
      // await this.cmtat.mint(address1, INITIAL_SUPPLY, { from: admin });
      ({ logs: this.logs1 } = await this.cmtat.mintBatch(
        TOKEN_HOLDER,
        TOKEN_SUPPLY_BY_HOLDERS,
        {
          from: admin
        }
      ));
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(
        INITIAL_SUPPLY
      )
    })

    it('testCanBeBurntBatchByAdmin', async function () {
      // Act
      // Burn
      this.logs = await this.cmtat.burnBatch(
        TOKEN_HOLDER,
        TOKEN_BY_HOLDERS_TO_BURN,
        REASON,
        {
          from: admin
        }
      )
      // Assert
      // emits a Transfer event
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent(this.logs, 'Transfer', {
          from: TOKEN_HOLDER[i],
          to: ZERO_ADDRESS,
          value: TOKEN_BY_HOLDERS_TO_BURN[i]
        })
      }

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent(this.logs, 'Burn', {
          owner: TOKEN_HOLDER[i],
          value: TOKEN_BY_HOLDERS_TO_BURN[i],
          reason: REASON
        })
      }
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(
          TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i]
        )
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(
        TOTAL_SUPPLY_AFTER_BURN
      )
    })

    it('testCanBeBurntBatchByBurnerRole', async function () {
      // Arrange
      await this.cmtat.grantRole(BURNER_ROLE, address2, { from: admin })

      // Act
      // Burn
      this.logs = await this.cmtat.burnBatch(
        TOKEN_HOLDER,
        TOKEN_BY_HOLDERS_TO_BURN,
        REASON,
        {
          from: address2
        }
      )

      // Assert
      // emits a Transfer event
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent(this.logs, 'Transfer', {
          from: TOKEN_HOLDER[i],
          to: ZERO_ADDRESS,
          value: TOKEN_BY_HOLDERS_TO_BURN[i]
        })
      }

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent(this.logs, 'Burn', {
          owner: TOKEN_HOLDER[i],
          value: TOKEN_BY_HOLDERS_TO_BURN[i]
        })
      }
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(
          TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i]
        )
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(
        TOTAL_SUPPLY_AFTER_BURN
      )
    })

    it('testCannotBeBurntIfOneBalanceExceeds', async function () {
      const TOKEN_BY_HOLDERS_TO_BURN_FAIL = [BN(5), BN(50), BN(5000000)]
      const ADDRESS2_BALANCE = await this.cmtat.balanceOf(address2)
      // Act
      await expectRevertCustomError(
        this.cmtat.burnBatch(
          TOKEN_HOLDER,
          TOKEN_BY_HOLDERS_TO_BURN_FAIL,
          '',
          { from: admin }
        ),
        'ERC20InsufficientBalance',
        [address2, ADDRESS2_BALANCE, TOKEN_BY_HOLDERS_TO_BURN_FAIL[2]]
      )
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      await expectRevertCustomError(
        this.cmtat.burnBatch(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, '', {
          from: address2
        }),
        'AccessControlUnauthorizedAccount',
        [address2, BURNER_ROLE]
      )
    })

    it('testCannotburnBatchIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_HOLDER_INVALID = [admin, address1]
      await expectRevertCustomError(
        this.cmtat.burnBatch(
          TOKEN_HOLDER_INVALID,
          TOKEN_BY_HOLDERS_TO_BURN,
          REASON,
          { from: admin }
        ),
        'CMTAT_BurnModule_AccountsValueslengthMismatch',
        []
      )
    })

    it('testCannotburnBatchIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const TOKEN_HOLDER_INVALID = [admin, address1, address1, address1]
      await expectRevertCustomError(
        this.cmtat.burnBatch(
          TOKEN_HOLDER_INVALID,
          TOKEN_BY_HOLDERS_TO_BURN,
          REASON,
          { from: admin }
        ),
        'CMTAT_BurnModule_AccountsValueslengthMismatch',
        []
      )
    })

    it('testCannotburnBatchIfAccountsIsEmpty', async function () {
      const TOKEN_ADDRESS_TOS_INVALID = []
      await expectRevertCustomError(
        this.cmtat.burnBatch(
          TOKEN_ADDRESS_TOS_INVALID,
          TOKEN_BY_HOLDERS_TO_BURN,
          REASON,
          { from: admin }
        ),
        'CMTAT_BurnModule_EmptyAccounts',
        []
      )
    })
  })
}
module.exports = ERC20BurnModuleCommon
