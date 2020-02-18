const { expectEvent, shouldFail } = require('openzeppelin-test-helpers');
require('chai/register-should');

const CMTA20 = artifacts.require('CMTA20');
const RuleEngineMock = artifacts.require('RuleEngineMock');
const zero = "0x0000000000000000000000000000000000000000";

contract('CMTA20', function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
  beforeEach(async function () {
    this.cmta20 = await CMTA20.new('CMTA 20', 'CMTA20', 'admin@cmta.ch', { from: owner });
  });

  context('Token structure', function () {
    it('has the defined name', async function () {
      (await this.cmta20.name()).should.equal('CMTA 20');
    });
    it('has the defined symbol', async function () {
      (await this.cmta20.symbol()).should.equal('CMTA20');
    });
    it('has the defined contact', async function () {
      (await this.cmta20.contact()).should.equal('admin@cmta.ch');
    });
    it('has no rule engine set by default', async function () {
      (await this.cmta20.ruleEngine()).should.equal('0x0000000000000000000000000000000000000000');
    });
    it('cannot be fractionned', async function () {
      (await this.cmta20.decimals()).should.be.bignumber.equal('0');
    });
  });

  context('Rule Engine', function () {
    it('can be changed by the owner', async function () {
      ({ logs: this.logs } = await this.cmta20.setRuleEngine(fakeRuleEngine, {from: owner}));
    }); 
    
    it('emits a LogRuleEngineSet event', function () {
      expectEvent.inLogs(this.logs, 'LogRuleEngineSet', { newRuleEngine: fakeRuleEngine });
    });

    it('reverts when calling from non-owner', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.setRuleEngine(fakeRuleEngine, { from: address1 }), 'OW01');
    });
  });

  context('Contact', function () {
    it('can be changed by the owner', async function () {
      ({ logs: this.logs } = await this.cmta20.setContact('admin2@cmta.ch', {from: owner}));
    }); 
    
    it('emits a LogContactSet event', function () {
      expectEvent.inLogs(this.logs, 'LogContactSet', { contact: 'admin2@cmta.ch' });
    });

    it('reverts when calling from non-owner', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.setContact('admin2@cmta.ch', { from: address1 }), 'OW01');
    });
  });

  context('Identities', function () {
    it('can be set by the shareholder and read from owner', async function () {
      await this.cmta20.setMyIdentity('0x1234567890', {from: address1});
      (await this.cmta20.identity(address1)).should.equal('0x1234567890');
    }); 
  });
  
  context('Issuing', function () {
    it('can be issued as the owner', async function () {
      /* Check first balance */
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('0');

      /* Issue 20 and check balances and total supply */
      ({ logs: this.logs1 } = await this.cmta20.issue(20, {from: owner}));
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('20');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('20');

      /* Issue 50 and check intermediate balances and total supply */
      ({ logs: this.logs2 } = await this.cmta20.issue(50, {from: owner}));
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('70');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('70');
    }); 

    it('emits a Transfer event', function () {
      expectEvent.inLogs(this.logs1, 'Transfer', { from: zero, to: owner, value: '20' });
      expectEvent.inLogs(this.logs2, 'Transfer', { from: zero, to: owner, value: '50' });
    });

    it('emits a LogIssued event', function () {
      expectEvent.inLogs(this.logs1, 'LogIssued', { value: '20' });
      expectEvent.inLogs(this.logs2, 'LogIssued', { value: '50' });
    });

    it('reverts when issuing from non-owner', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.issue(20, { from: address1 }), 'OW01');
    });
  });

  context('Redeeming', function () {
    beforeEach(async function () {
      await this.cmta20.issue(70, {from: owner});
    });

    it('can be redeemed as the owner', async function () {
      /* Redeem 20 and check balances and total supply */
      ({ logs: this.logs1 } = await this.cmta20.redeem(20, {from: owner}));
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('50');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('50');

      /* Redeem 50 and check balances and total supply */
      ({ logs: this.logs2 } = await this.cmta20.redeem(50, {from: owner}));
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('0');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('0');
    }); 
    
    it('emits a Transfer event', function () {
      expectEvent.inLogs(this.logs1, 'Transfer', { from: owner, to: zero, value: '20' });
      expectEvent.inLogs(this.logs2, 'Transfer', { from: owner, to: zero, value: '50' });
    });

    it('emits a LogRedeemed event', function () {
      expectEvent.inLogs(this.logs1, 'LogRedeemed', { value: '20' });
      expectEvent.inLogs(this.logs2, 'LogRedeemed', { value: '50' });
    });

    it('reverts when redeeming from non-owner', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.redeem(20, { from: address1 }), 'OW01');
    });

    it('reverts when redeeming more than the owner balance', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.redeem(100, { from: owner }), 'SafeMath: subtraction overflow');
    });
  });

  context('Reassigning', function () {
    beforeEach(async function () {
      await this.cmta20.issue(70, {from: owner});
      await this.cmta20.transfer(address1, 50, {from: owner});
    });

    it('can be reassigned as the owner from address1 to address2', async function () {

      ({ logs: this.logs } = await this.cmta20.reassign(address1, address2, {from: owner}));
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('20');
      (await this.cmta20.balanceOf(address1)).should.be.bignumber.equal('0');
      (await this.cmta20.balanceOf(address2)).should.be.bignumber.equal('50');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('70');
    }); 
    
    it('emits a LogReassigned event and a Transfer event', function () {
      expectEvent.inLogs(this.logs, 'LogReassigned', { original: address1, replacement: address2, value: '50' });
      expectEvent.inLogs(this.logs, 'Transfer', { from: address1, to: address2, value: '50' });
    });

    it('reverts when reassigning from non-owner', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.reassign(address1, address2, { from: address3 }), 'OW01');
    });

    it('reverts when reassigning when contract is paused', async function () {
      await this.cmta20.pause({from: owner});
      await shouldFail.reverting.withMessage(this.cmta20.reassign(address1, address2, { from: owner }), 'Pausable: paused');
    });

    it('reverts when reassigning when original is 0x0', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.reassign(zero, address2, { from: owner }), 'CM01');
    });

    it('reverts when reassigning when original is 0x0', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.reassign(address1, zero, { from: owner }), 'CM02');
    });

    it('reverts when reassigning when original is the same as replacement', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.reassign(address1, address1, { from: owner }), 'CM03');
    });

    it('reverts when reassigning from an original address that holds not tokens', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.reassign(address3, address1, { from: owner }), 'CM05');
    });
  });

  context('Destroying', function () {
    beforeEach(async function () {
      await this.cmta20.issue(100, {from: owner});
      await this.cmta20.transfer(address1, 31, {from: owner});
      await this.cmta20.transfer(address2, 32, {from: owner});
      await this.cmta20.transfer(address3, 33, {from: owner});
    });

    it('can be destroyed as the owner', async function () {
      ({ logs: this.logs } = await this.cmta20.destroy([address1, address2], {from: owner}));
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('67');
      (await this.cmta20.balanceOf(address1)).should.be.bignumber.equal('0');
      (await this.cmta20.balanceOf(address2)).should.be.bignumber.equal('0');
      (await this.cmta20.balanceOf(address3)).should.be.bignumber.equal('33');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('100');
    }); 
    
    it('emits a LogDestroyed event and multiple Transfer events', function () {
      expectEvent.inLogs(this.logs, 'LogDestroyed', { });
      expectEvent.inLogs(this.logs, 'Transfer', { from: address1, to: owner, value: '31' });
      expectEvent.inLogs(this.logs, 'Transfer', { from: address2, to: owner, value: '32' });
    });

    it('reverts when destroying from non-owner', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.destroy([address1, address2], { from: address3 }), 'OW01');
    });

    it('reverts when destroying with owner contained in shareholders array', async function () {
      await shouldFail.reverting.withMessage(this.cmta20.destroy([owner, address1, address2], { from: owner }), 'CM06');
    });
  });

  context('Allowing', function () {
    it('allows address1 to define a spending allowance for address3', async function () {
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('0');
      ({logs: this.logs} = await this.cmta20.approve(address3, 20, {from: address1}));
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('20');     
    });

    it('emits an Approval event', function () {
      expectEvent.inLogs(this.logs, 'Approval', { owner: address1, spender: address3, value: '20'});
    });

    it('allows address1 to increase the allowance for address3', async function () {
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('0');
      await this.cmta20.approve(address3, 20, {from: address1});
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('20');  
      ({logs: this.logs} = await this.cmta20.increaseAllowance(address3, 10, {from: address1}));
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('30');           
    });

    it('emits an Approval event', function () {
      expectEvent.inLogs(this.logs, 'Approval', { owner: address1, spender: address3, value: '30'});
    });

    it('allows address1 to decrease the allowance for address3', async function () {
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('0');
      await this.cmta20.approve(address3, 20, {from: address1});
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('20');  
      ({logs: this.logs} = await this.cmta20.decreaseAllowance(address3, 10, {from: address1}));
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('10');           
    });

    it('emits an Approval event', function () {
      expectEvent.inLogs(this.logs, 'Approval', { owner: address1, spender: address3, value: '10'});
    });

    it('allows address1 to redefine a spending allowance for address3', async function () {
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('0');
      await this.cmta20.approve(address3, 20, {from: address1});
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('20');     
      ({logs: this.logs} = await this.cmta20.approve(address3, 50, {from: address1}));
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('50'); 
    }); 
    
    it('emits an Approval event', function () {
      expectEvent.inLogs(this.logs, 'Approval', { owner: address1, spender: address3, value: '50'});
    });

    it('reverts when approving when contract is paused', async function () {
      await this.cmta20.pause({from: owner});
      await shouldFail.reverting.withMessage(this.cmta20.approve(address3, 20, {from: address1}), 'Pausable: paused');
    });
  });

  context('Transferring', function () {
    beforeEach(async function () {
      await this.cmta20.issue(100, {from: owner});
      await this.cmta20.transfer(address1, 31, {from: owner});
      await this.cmta20.transfer(address2, 32, {from: owner});
      await this.cmta20.transfer(address3, 33, {from: owner});
    });

    it('can check if transfer is valid', async function () {
      (await this.cmta20.canTransfer(address1, address2, 11)).should.equal(true);
      (await this.cmta20.detectTransferRestriction(address1, address2, 11)).should.be.bignumber.equal("0");
      (await this.cmta20.messageForTransferRestriction(0)).should.equal("No restriction");
    });

    it('allows address1 to transfer tokens to address2', async function () {
      await this.cmta20.transfer(address2, 11, {from: address1}); 
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('4');
      (await this.cmta20.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmta20.balanceOf(address2)).should.be.bignumber.equal('43');
      (await this.cmta20.balanceOf(address3)).should.be.bignumber.equal('33');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('100');           
    });

    it('reverts if address1 transfers more tokens than he owns to address2', async function () {
      await shouldFail.reverting(this.cmta20.transfer(address2, 50, {from: address1}));        
    });

    it('reverts if address1 transfers tokens to address2 when paused', async function () {
      await this.cmta20.pause({from: owner});
      await shouldFail.reverting.withMessage(this.cmta20.transfer(address2, 10, {from: address1}), 'Pausable: paused');     
    });

    it('allows address3 to transfer tokens from address1 to address2 with the right allowance', async function () {
      /* Define allowance */
      await this.cmta20.approve(address3, 20, {from: address1});

      /* Transfer */
      await this.cmta20.transferFrom(address1, address2, 11, {from: address3}); 
      (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('4');
      (await this.cmta20.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmta20.balanceOf(address2)).should.be.bignumber.equal('43');
      (await this.cmta20.balanceOf(address3)).should.be.bignumber.equal('33');
      (await this.cmta20.totalSupply()).should.be.bignumber.equal('100');           
    });

    it('reverts if address3 transfers more tokens than the allowance from address1 to address2', async function () {
      /* Define allowance */
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('0');
      await this.cmta20.approve(address3, 20, {from: address1});
      (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('20');

      /* Transfer */
      await shouldFail.reverting(this.cmta20.transferFrom(address1, address2, 31, {from: address3}));        
    });

    it('reverts if address3 transfers more tokens than address1 owns from address1 to address2', async function () {
      await this.cmta20.approve(address3, 1000, {from: address1});
      await shouldFail.reverting(this.cmta20.transferFrom(address1, address2, 50, {from: address3}));        
    });

    it('reverts if address3 transfers tokens from address1 to address2 when paused', async function () {
      /* Define allowance */
      await this.cmta20.approve(address3, 20, {from: address1});

      await this.cmta20.pause({from: owner});
      (await this.cmta20.canTransfer(address1, address2, 10)).should.equal(false);
      (await this.cmta20.detectTransferRestriction(address1, address2, 10)).should.be.bignumber.equal("1");
      (await this.cmta20.messageForTransferRestriction(1)).should.equal("All transfers paused");
      await shouldFail.reverting.withMessage(this.cmta20.transferFrom(address1, address2, 10, {from: address3}), 'Pausable: paused');     
    });

    context('Transferring with Rule Engine set', function () {
      beforeEach(async function () {
        this.ruleEngineMock = await RuleEngineMock.new({ from: owner });
        await this.cmta20.setRuleEngine(this.ruleEngineMock.address, {from: owner});
      });

      it('can check if transfer is valid', async function () {
        (await this.cmta20.canTransfer(address1, address2, 11)).should.equal(true);
        (await this.cmta20.detectTransferRestriction(address1, address2, 11)).should.be.bignumber.equal("0");
        (await this.cmta20.messageForTransferRestriction(0)).should.equal("No restriction");
        (await this.cmta20.canTransfer(address1, address2, 21)).should.equal(false);
        (await this.cmta20.detectTransferRestriction(address1, address2, 21)).should.be.bignumber.equal("10");
        (await this.cmta20.messageForTransferRestriction(10)).should.equal("Amount too high");
      });
  
      it('allows address1 to transfer tokens to address2', async function () {
        await this.cmta20.transfer(address2, 11, {from: address1}); 
        (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('4');
        (await this.cmta20.balanceOf(address1)).should.be.bignumber.equal('20');
        (await this.cmta20.balanceOf(address2)).should.be.bignumber.equal('43');
        (await this.cmta20.balanceOf(address3)).should.be.bignumber.equal('33');
        (await this.cmta20.totalSupply()).should.be.bignumber.equal('100');           
      });
  
      it('reverts if address1 transfers more tokens than rule allows', async function () {
        await shouldFail.reverting.withMessage(this.cmta20.transfer(address2, 21, {from: address1}), "CM04");        
      });

      it('allows address3 to transfer tokens from address1 to address2 with the right allowance', async function () {
        /* Define allowance */
        await this.cmta20.approve(address3, 21, {from: address1});
  
        /* Transfer */
        await this.cmta20.transferFrom(address1, address2, 11, {from: address3}); 
        (await this.cmta20.balanceOf(owner)).should.be.bignumber.equal('4');
        (await this.cmta20.balanceOf(address1)).should.be.bignumber.equal('20');
        (await this.cmta20.balanceOf(address2)).should.be.bignumber.equal('43');
        (await this.cmta20.balanceOf(address3)).should.be.bignumber.equal('33');
        (await this.cmta20.totalSupply()).should.be.bignumber.equal('100');           
      });
  
      it('reverts if address3 transfers more tokens than the allowance from address1 to address2', async function () {
        /* Define allowance */
        (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('0');
        await this.cmta20.approve(address3, 21, {from: address1});
        (await this.cmta20.allowance(address1, address3)).should.be.bignumber.equal('21');
  
        /* Transfer */
        await shouldFail.reverting.withMessage(this.cmta20.transferFrom(address1, address2, 21, {from: address3}), "CM04");        
      });
    });
  });
});
