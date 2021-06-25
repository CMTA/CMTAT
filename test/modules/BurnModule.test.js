const { expectEvent, expectRevert } = require('openzeppelin-test-helpers');
const { BURNER_ROLE, ZERO_ADDRESS } = require('../utils');
require('chai/register-should');

const CMTAT = artifacts.require('CMTAT');

contract('BurnModule', function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
  beforeEach(async function () {
    this.cmtat = await CMTAT.new({ from: owner });
    this.cmtat.initialize('CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner });
  });

  context('Burn', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 50, {from: owner});
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('50');
    });

    it('can be burnt as the owner with allowance', async function () {
      await this.cmtat.approve(owner, 50, {from: address1 });
      // Burn 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.burnFrom(address1, 20, {from: owner}));
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('30');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('30');

      // Burn 30 and check balances and total supply
      ({ logs: this.logs2 } = await this.cmtat.burnFrom(address1, 30, {from: owner}));
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('0');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('0');
    }); 
    
    it('emits a Transfer event', function () {
      expectEvent.inLogs(this.logs1, 'Transfer', { from: address1, to: ZERO_ADDRESS, value: '20' });
      expectEvent.inLogs(this.logs2, 'Transfer', { from: address1, to: ZERO_ADDRESS, value: '30' });
    });

    it('emits a Burn event', function () {
      expectEvent.inLogs(this.logs1, 'Burn', { owner: address1, amount: '20' });
      expectEvent.inLogs(this.logs2, 'Burn', { owner: address1, amount: '30' });
    });

    it('can be burnt as anyone with burner role and allowance', async function () {
      await this.cmtat.grantRole(BURNER_ROLE, address2, {from: owner});
      await this.cmtat.approve(address2, 50, {from: address1 });
      await this.cmtat.burnFrom(address1, 20, {from: address2});
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('30');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('30');
    }); 

    it('reverts when burning without allowance', async function () {
      await expectRevert(this.cmtat.burnFrom(address1, 20, {from: owner}), 'CMTAT: burn amount exceeds allowance');
    });

    it('reverts when burning without burner role', async function () {
      await expectRevert(this.cmtat.burnFrom(address1, 20, { from: address2 }), 'CMTAT: must have burner role to burn');
    });
  });
});
