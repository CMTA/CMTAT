const { expectEvent, expectRevert } = require('openzeppelin-test-helpers');
require('chai/register-should');
const { ENFORCER_ROLE } = require('../utils');

const CMTAT = artifacts.require('CMTAT');

contract('EnforcementModule', function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
  beforeEach(async function () {
    this.cmtat = await CMTAT.new({ from: owner });
    this.cmtat.initialize('CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner });
  });

  context('Enforcement', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 50, {from: owner});
    });

    it('can force transfer as the owner from address1 to address2 as owner', async function () {
      ({ logs: this.logs } = await this.cmtat.enforceTransfer(address1, address2, 20, 'Bad guy', {from: owner}));
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('30');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('20');
    }); 

    it('emits a Enforcement event and a Transfer event', function () {
      expectEvent.inLogs(this.logs, 'Enforcement', { enforcer: owner, owner: address1, amount: '20', reason: 'Bad guy' });
      expectEvent.inLogs(this.logs, 'Transfer', { from: address1, to: address2, value: '20' });
    });

    it('can force transfer as the owner from address1 to address2 as anyone with enforce role', async function () {
      await this.cmtat.grantRole(ENFORCER_ROLE, address3, {from: owner});
      await this.cmtat.enforceTransfer(address1, address2, 20, 'Bad guy', {from: address3});
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('30');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('20');
    }); 

    it('reverts when trying to enforce transfer from non-enforcer', async function () {
      await expectRevert(this.cmtat.enforceTransfer(address1, address2, 20, 'Bad guy', { from: address3 }), 'AccessControl: account ' + address3.toLowerCase() + ' is missing role ' + ENFORCER_ROLE);
    });
  });

  context('Freeze', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 50, {from: owner});
    });

    it('can freeze an account as the owner', async function () {
      (await this.cmtat.frozen(address1)).should.equal(false);
      ({ logs: this.logs } = await this.cmtat.freeze(address1, {from: owner}));
      (await this.cmtat.frozen(address1)).should.equal(true);
    }); 
    
    it('emits a Freeze event', function () {
      expectEvent.inLogs(this.logs, 'Freeze', { enforcer: owner, owner: address1 });
    });

    it('can freeze an account as anyone with the enforcer role', async function () {
      await this.cmtat.grantRole(ENFORCER_ROLE, address3, {from: owner});
      (await this.cmtat.frozen(address1)).should.equal(false);
      await this.cmtat.freeze(address1, {from: address3});
      (await this.cmtat.frozen(address1)).should.equal(true);
    }); 

    it('can unfreeze an account as the owner', async function () {
      await this.cmtat.freeze(address1, {from: owner});
      (await this.cmtat.frozen(address1)).should.equal(true);
      ({ logs: this.logs } = await this.cmtat.unfreeze(address1, {from: owner}));
      (await this.cmtat.frozen(address1)).should.equal(false);
    }); 

    it('can unfreeze an account as anyone with the enforcer role', async function () {
      await this.cmtat.freeze(address1, {from: owner});
      (await this.cmtat.frozen(address1)).should.equal(true);
      await this.cmtat.grantRole(ENFORCER_ROLE, address3, {from: owner});
      await this.cmtat.unfreeze(address1, {from: address3});
      (await this.cmtat.frozen(address1)).should.equal(false);
    }); 
    
    it('emits an Unfreeze event', function () {
      expectEvent.inLogs(this.logs, 'Unfreeze', { enforcer: owner, owner: address1 });
    });

    it('reverts when freezing from non-enforcer', async function () {
      await expectRevert(this.cmtat.freeze(address1, { from: address3 }), 'AccessControl: account ' + address3.toLowerCase() + ' is missing role ' + ENFORCER_ROLE);
    });

    it('reverts when unfreezing from non-enforcer', async function () {
      await expectRevert(this.cmtat.unfreeze(address1, { from: address3 }), 'AccessControl: account ' + address3.toLowerCase() + ' is missing role ' + ENFORCER_ROLE);
    });
  });
});
