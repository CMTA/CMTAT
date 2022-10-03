pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "./HelperContract.sol";
import "../src/mocks/RuleEngineMock.sol";

contract RuleEngineTest is Test, HelperContract, ValidationModule {
  RuleEngineMock fakeRuleEngine = new RuleEngineMock();
  uint256 resUint256;
  function setUp() public {
    vm.prank(OWNER);
    CMTAT_CONTRACT = new CMTAT();
    CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
  }

  // can be changed by the owner
  function testCanBeChangedByOwner () public {
    vm.prank(OWNER);
    vm.expectEmit(true, false, false, false);
    emit RuleEngineSet(address(fakeRuleEngine));
    CMTAT_CONTRACT.setRuleEngine(fakeRuleEngine);
  }
  

  // reverts when calling from non-owner
  function testCannotCallByNonOwner () public {
    vm.prank(ADDRESS1);
    string memory message = string(abi.encodePacked('AccessControl: account ', 
    vm.toString(ADDRESS1),' is missing role ', DEFAULT_ADMIN_ROLE_HASH));
    vm.expectRevert(bytes(message));
    CMTAT_CONTRACT.setRuleEngine(fakeRuleEngine);
  }
}

// Transferring with Rule Engine set
contract RuleEngineSetTest is Test, HelperContract, ValidationModule {
  RuleEngineMock ruleEngineMock;
  uint256 resUint256;
  function setUp() public {
    vm.prank(OWNER);
    CMTAT_CONTRACT = new CMTAT();
    CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');

    // Config perso
    vm.prank(OWNER);
    ruleEngineMock = new RuleEngineMock();
    vm.prank(OWNER);
    CMTAT_CONTRACT.mint(ADDRESS1, 31);
    vm.prank(OWNER);
    CMTAT_CONTRACT.mint(ADDRESS2, 32);
    vm.prank(OWNER);
    CMTAT_CONTRACT.mint(ADDRESS3, 33);
    vm.prank(OWNER);
    CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
  }

  // can check if transfer is valid
  function testCanCheckTransferIsValid () public {
    uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(ADDRESS1, ADDRESS2, 11);
    assertEq(res1, 0);
    string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(0);
    assertEq(message1, "No restriction");
    uint8 res2 = CMTAT_CONTRACT.detectTransferRestriction(ADDRESS1, ADDRESS2, 21);
    assertEq(res2, 10);
    string memory message2 = CMTAT_CONTRACT.messageForTransferRestriction(10);
    assertEq(message2, "Amount too high");
  }

  // allows ADDRESS1 to transfer tokens to ADDRESS2
  function testAllowTransfer () public {
    vm.prank(ADDRESS1);
    CMTAT_CONTRACT.transfer(ADDRESS2, 11);
    resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
    assertEq(resUint256, 20);
    resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
    assertEq(resUint256, 43);
    resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
    assertEq(resUint256, 33);        
  }

  // reverts if ADDRESS1 transfers more tokens than rule allows
  function testCannotTransferRuleAllows() public {
    vm.prank(ADDRESS1);
    vm.expectRevert(bytes('CMTAT: transfer rejected by validation module'));
    CMTAT_CONTRACT.transfer(ADDRESS2, 21);
  }
}

