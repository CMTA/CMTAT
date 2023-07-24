const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { BURNER_ROLE, ZERO_ADDRESS } = require('../utils')
const { should } = require('chai').should()

function BurnModuleCommon (admin, address1, address2) {
  context('Burn', function () {
    const INITIAL_SUPPLY = new BN(50)
    const REASON = 'BURN_TEST'
    const VALUE1 = new BN(20)
    const DIFFERENCE = INITIAL_SUPPLY.sub(VALUE1)

    beforeEach(async function () {
      await this.cmtat.mint(address1, INITIAL_SUPPLY, { from: admin });
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(INITIAL_SUPPLY)
    })

    it('testCanBeBurntByAdmin', async function () {
      // Act
      // Burn 20
      ({ logs: this.logs1 } = await this.cmtat.forceBurn(address1, VALUE1, REASON, {
        from: admin
      }))
      // Assert
      // emits a Transfer event
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: VALUE1
      })
      // Emits a Burn event
      expectEvent.inLogs(this.logs1, 'Burn', {
        owner: address1,
        amount: VALUE1,
        reason: REASON
      });
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(DIFFERENCE);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(DIFFERENCE);

      // Burn 30
      // Act
      ({ logs: this.logs2 } = await this.cmtat.forceBurn(address1, DIFFERENCE, REASON, {
        from: admin
      }))
      // Assert
      // Emits a Transfer event
      expectEvent.inLogs(this.logs2, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: DIFFERENCE
      })
      // Emits a Burn event
      expectEvent.inLogs(this.logs2, 'Burn', {
        owner: address1,
        amount: DIFFERENCE,
        reason: REASON
      });
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(BN(0));
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(BN(0))
    })

    it('testCanBeBurntByBurnerRole', async function () {
      // Arrange
      await this.cmtat.grantRole(BURNER_ROLE, address2, { from: admin });
      // Act
      ({ logs: this.logs } = await this.cmtat.forceBurn(address1, VALUE1, REASON, { from: address2 }));
      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(DIFFERENCE);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(DIFFERENCE)

      // Emits a Transfer event
      expectEvent.inLogs(this.logs, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: VALUE1
      })
      // Emits a Burn event
      expectEvent.inLogs(this.logs, 'Burn', {
        owner: address1,
        amount: VALUE1,
        reason: REASON
      })
    })

    it('testCannotBeBurntIfBalanceExceeds', async function () {
      // Act
      await expectRevert(
        this.cmtat.forceBurn(address1, 200, '', { from: admin }),
        'ERC20: burn amount exceeds balance'
      )
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      // Act
      await expectRevert(
        this.cmtat.forceBurn(address1, 20, '', { from: address2 }),
        'AccessControl: account ' +
            address2.toLowerCase() +
            ' is missing role ' +
            BURNER_ROLE
      )
    })
  })
  context('BurnBatch', function () {
    const REASON = 'BURN_TEST'
    const TOKEN_HOLDER = [admin, address1, address2]
    const TOKEN_SUPPLY_BY_HOLDERS = [BN(10), BN(100), BN(1000)]
    const INITIAL_SUPPLY = TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => { return a.add(b) })
    const TOKEN_BY_HOLDERS_TO_BURN = [BN(5), BN(50), BN(500)]
    const TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN = [
      TOKEN_SUPPLY_BY_HOLDERS[0].sub(TOKEN_BY_HOLDERS_TO_BURN[0]),
      TOKEN_SUPPLY_BY_HOLDERS[1].sub(TOKEN_BY_HOLDERS_TO_BURN[1]),
      TOKEN_SUPPLY_BY_HOLDERS[2].sub(TOKEN_BY_HOLDERS_TO_BURN[2])]
    const TOTAL_SUPPLY_AFTER_BURN = INITIAL_SUPPLY.sub(TOKEN_BY_HOLDERS_TO_BURN.reduce((a, b) => { return a.add(b) }))

    beforeEach(async function () {
      // await this.cmtat.mint(address1, INITIAL_SUPPLY, { from: admin });
      ({ logs: this.logs1 } = await this.cmtat.mintBatch(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS, {
        from: admin
      }));
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(INITIAL_SUPPLY)
    })

    it('testCanBeBurntBatchByAdmin', async function () {
      // Act
      // Burn
      ({ logs: this.logs1 } = await this.cmtat.forceBurnBatch(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, REASON, {
        from: admin
      }))
      // Assert
      // emits a Transfer event
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Transfer', {
          from: TOKEN_HOLDER[i],
          to: ZERO_ADDRESS,
          value: TOKEN_BY_HOLDERS_TO_BURN[i]
        })
      }

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Burn', {
          owner: TOKEN_HOLDER[i],
          amount: TOKEN_BY_HOLDERS_TO_BURN[i],
          reason: REASON
        })
      }
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i])
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(TOTAL_SUPPLY_AFTER_BURN)
    })

    it('testCanBeBurntByBurnerRole', async function () {
      // Arrange
      await this.cmtat.grantRole(BURNER_ROLE, address2, { from: admin });

      // Act
      // Burn
      ({ logs: this.logs1 } = await this.cmtat.forceBurnBatch(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, REASON, {
        from: address2
      }))
      // Assert
      // emits a Transfer event
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Transfer', {
          from: TOKEN_HOLDER[i],
          to: ZERO_ADDRESS,
          value: TOKEN_BY_HOLDERS_TO_BURN[i]
        })
      }

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Burn', {
          owner: TOKEN_HOLDER[i],
          amount: TOKEN_BY_HOLDERS_TO_BURN[i]
        })
      }
      // Check balances and total supply
      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(TOKEN_BALANCE_BY_HOLDERS_AFTER_BURN[i])
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(TOTAL_SUPPLY_AFTER_BURN)
    })

    it('testCannotBeBurntIfOneBalanceExceeds', async function () {
      const TOKEN_BY_HOLDERS_TO_BURN_FAIL = [BN(5), BN(50), BN(5000000)]
      // Act
      await expectRevert(
        this.cmtat.forceBurnBatch(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN_FAIL, '', { from: admin }),
        'ERC20: burn amount exceeds balance'
      )
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      // Act
      await expectRevert(
        this.cmtat.forceBurnBatch(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN, '', { from: address2 }),
        'AccessControl: account ' +
            address2.toLowerCase() +
            ' is missing role ' +
            BURNER_ROLE
      )
    })
  })
}
module.exports = BurnModuleCommon
