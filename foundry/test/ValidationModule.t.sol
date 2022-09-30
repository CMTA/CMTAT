pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "./HelperContract.sol";

const RuleEngineMock = artifacts.require('RuleEngineMock');

contract RuleEngineTest {
   function setUp() public {
     vm.prank(OWNER);
     CMTAT_CONTRACT = new CMTAT();
     CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    }

    // can be changed by the owner
    function () {
      ({ logs: this.logs } = await this.cmtat.setRuleEngine(fakeRuleEngine, {from: owner}));
    }); 
    
    // emits a RuleEngineSet event
    function () {
      expectEvent.inLogs(this.logs, 'RuleEngineSet', { newRuleEngine: fakeRuleEngine });
    });

    // reverts when calling from non-owner
    function () {
      await expectRevert(this.cmtat.setRuleEngine(fakeRuleEngine, { from: address1 }), 'AccessControl: account ' + address1.toLowerCase() + ' is missing role ' + DEFAULT_ADMIN_ROLE);
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

    // can check if transfer is valid
    function () {
      (await this.cmtat.detectTransferRestriction(address1, address2, 11)).should.be.bignumber.equal("0");
      (await this.cmtat.messageForTransferRestriction(0)).should.equal("No restriction");
      (await this.cmtat.detectTransferRestriction(address1, address2, 21)).should.be.bignumber.equal("10");
      (await this.cmtat.messageForTransferRestriction(10)).should.equal("Amount too high");
    });

    // allows address1 to transfer tokens to address2
    function () {
      await this.cmtat.transfer(address2, 11, {from: address1}); 
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
      (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal('33');        
    });

    // reverts if address1 transfers more tokens than rule allows
    function () {
      vm.prank(ADDRESS1);
      await expectRevert(this.cmtat.transfer(address2, 21), 'CMTAT: transfer rejected by validation module');        
    });
  });
});
