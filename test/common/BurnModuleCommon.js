const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { BURNER_ROLE, ZERO_ADDRESS } = require('../utils')
const { should } = require('chai').should()

function BurnModuleCommon (admin, address1, address2) {
  context('Burn', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 50, { from: admin });
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('50')
    })

    it('testCanBeBurntByAdminWithAllowance', async function () {
      const reason = 'BURN_TEST';
      // Act
      // Burn 20
      ({ logs: this.logs1 } = await this.cmtat.forceBurn(address1, 20, reason, {
        from: admin
      }))
      // Assert
      // emits a Transfer event
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: '20'
      })
      // Emits a Burn event
      expectEvent.inLogs(this.logs1, 'Burn', {
        owner: address1,
        amount: '20',
        reason
      });
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('30');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('30');

      // Burn 30
      // Act
      ({ logs: this.logs2 } = await this.cmtat.forceBurn(address1, 30, reason, {
        from: admin
      }))
      // Assert
      // Emits a Transfer event
      expectEvent.inLogs(this.logs2, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: '30'
      })
      // Emits a Burn event
      expectEvent.inLogs(this.logs2, 'Burn', {
        owner: address1,
        amount: '30',
        reason
      });
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('0');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('0')
    })

    it('testCanBeBurntByBurnerRole', async function () {
      const reason = 'BURN_TEST'
      // Arrange
      await this.cmtat.grantRole(BURNER_ROLE, address2, { from: admin });
      // Act
      ({ logs: this.logs } = await this.cmtat.forceBurn(address1, 20, reason, { from: address2 }));
      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('30');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('30')

      // Emits a Transfer event
      expectEvent.inLogs(this.logs, 'Transfer', {
        from: address1,
        to: ZERO_ADDRESS,
        value: '20'
      })
      // Emits a Burn event
      expectEvent.inLogs(this.logs, 'Burn', {
        owner: address1,
        amount: '20',
        reason
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
}
module.exports = BurnModuleCommon
