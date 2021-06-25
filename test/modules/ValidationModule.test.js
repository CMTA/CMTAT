const { expectEvent, expectRevert } = require('openzeppelin-test-helpers');
const { PAUSER_ROLE } = require('../utils');
require('chai/register-should');

const CMTAT = artifacts.require('CMTAT');
const RuleEngineMock = artifacts.require('RuleEngineMock');

contract('ValidationModule', function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
  beforeEach(async function () {
    this.cmtat = await CMTAT.new({ from: owner });
    this.cmtat.initialize('CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner });
  });

  context('Rule Engine', function () {
    it('can be changed by the owner', async function () {
      ({ logs: this.logs } = await this.cmtat.setRuleEngine(fakeRuleEngine, {from: owner}));
    }); 
    
    it('emits a RuleEngineSet event', function () {
      expectEvent.inLogs(this.logs, 'RuleEngineSet', { newRuleEngine: fakeRuleEngine });
    });

    it('reverts when calling from non-owner', async function () {
      await expectRevert(this.cmtat.setRuleEngine(fakeRuleEngine, { from: address1 }), 'CMTAT: must have admin role');
    });
  });

  context('Transferring with Rule Engine set', function () {
    beforeEach(async function () {
      this.ruleEngineMock = await RuleEngineMock.new({ from: owner });
      await this.cmtat.mint(address1, 31, {from: owner});
      await this.cmtat.mint(address2, 32, {from: owner});
      await this.cmtat.mint(address3, 33, {from: owner});
      await this.cmtat.setRuleEngine(this.ruleEngineMock.address, {from: owner});
    });

    it('can check if transfer is valid', async function () {
      (await this.cmtat.detectTransferRestriction(address1, address2, 11)).should.be.bignumber.equal("0");
      (await this.cmtat.messageForTransferRestriction(0)).should.equal("No restriction");
      (await this.cmtat.detectTransferRestriction(address1, address2, 21)).should.be.bignumber.equal("10");
      (await this.cmtat.messageForTransferRestriction(10)).should.equal("Amount too high");
    });

    it('allows address1 to transfer tokens to address2', async function () {
      await this.cmtat.transfer(address2, 11, {from: address1}); 
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
      (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal('33');        
    });

    it('reverts if address1 transfers more tokens than rule allows', async function () {
      await expectRevert(this.cmtat.transfer(address2, 21, {from: address1}), 'CMTAT: transfer rejected by validation module');        
    });
  });
});
