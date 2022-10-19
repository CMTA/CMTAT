const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')

function MintModuleCommon (owner, address1, address2) {
  context('Minting', function () {
    it('can be minted as the owner', async function () {
      // Check first balance
      (await this.cmtat.balanceOf(owner)).should.be.bignumber.equal('0');

      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, 20, {
        from: owner
      }));
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('20');

      // Issue 50 and check intermediate balances and total supply
      ({ logs: this.logs2 } = await this.cmtat.mint(address2, 50, {
        from: owner
      }));
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('50');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('70')
    })

    it('can be minted by anyone with minter role', async function () {
      await this.cmtat.grantRole(MINTER_ROLE, address1, { from: owner });
      // Check first balance
      (await this.cmtat.balanceOf(owner)).should.be.bignumber.equal('0');

      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, 20, {
        from: address1
      }));
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('20')
    })

    it('emits a Transfer event', function () {
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address1,
        value: '20'
      })
      expectEvent.inLogs(this.logs2, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address2,
        value: '50'
      })
    })

    it('emits a Mint event', function () {
      expectEvent.inLogs(this.logs1, 'Mint', {
        beneficiary: address1,
        amount: '20'
      })
      expectEvent.inLogs(this.logs2, 'Mint', {
        beneficiary: address2,
        amount: '50'
      })
    })

    it('reverts when issuing from non-owner', async function () {
      await expectRevert(
        this.cmtat.mint(address1, 20, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            MINTER_ROLE
      )
    })
  })
}
module.exports = MintModuleCommon
