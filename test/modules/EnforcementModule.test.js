const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const {should} = require('chai').should();
const { ENFORCER_ROLE } = require('../utils');

const CMTAT = artifacts.require('CMTAT');

contract('EnforcementModule', function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
  beforeEach(async function () {
    this.cmtat = await CMTAT.new({ from: owner });
    this.cmtat.initialize(owner, _, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner });
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
