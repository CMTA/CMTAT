pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "../src/CMTAT.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract AuthorizationModuleTest is Test, AuthorizationModule, PauseModule {
     string constant MINTER_ROLE_HASH  = 
    '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6';
     string constant DEFAULT_ROLE_HASH  = 
    '0x0000000000000000000000000000000000000000000000000000000000000000';
    CMTAT CMTAT_CONTRACT;
    address constant ZERO_ADDRESS = address(0);
    address constant OWNER = address(1);
    address constant ADDRESS1 = address(2);
    address constant ADDRESS2 = address(3);
    address constant ADDRESS3 = address(4);
 
    function setUp() public {
     
      vm.prank(OWNER);
      CMTAT_CONTRACT = new CMTAT();
      CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    }


    // can grant role as the owner
    function testCanGrantRoleAsOwner() public {
      vm.prank(OWNER);
      vm.expectEmit(true, true, false, true);
      emit RoleGranted(PAUSER_ROLE, ADDRESS1,  OWNER );
      
      CMTAT_CONTRACT.grantRole(PAUSER_ROLE, ADDRESS1);
      bool res1 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertEq(res1, true);
    }

    // can revoke role as the owner
    function testRevokeRoleAsOwner() public {
      vm.prank(OWNER);
      CMTAT_CONTRACT.grantRole(PAUSER_ROLE, ADDRESS1);
      bool res1 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertEq(res1, true);
      
      vm.prank(OWNER);
      vm.expectEmit(true, true, false, true);
       // emits a RoleRevoked event
      emit RoleRevoked(PAUSER_ROLE, ADDRESS1,  OWNER );
      CMTAT_CONTRACT.revokeRole(PAUSER_ROLE, ADDRESS1);
      bool res2 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertFalse(res2);
    }

    // reverts when granting from non-owner
    function testCannotGrantFromNonOwner() public {
      bool res1 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertFalse(res1);
      
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS2),' is missing role ', DEFAULT_ROLE_HASH));
      vm.expectRevert(bytes(message));
      vm.prank(ADDRESS2);
      CMTAT_CONTRACT.grantRole(PAUSER_ROLE, ADDRESS1);
      
      bool res2 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertFalse(res2);
    }

    // reverts when revoking from non-owner
    function testCannotRevokeFromNonOwner() public {
      bool res1 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertFalse(res1);
      
      vm.prank(OWNER);
      CMTAT_CONTRACT.grantRole(PAUSER_ROLE, ADDRESS1);
      bool res2 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertEq(res2, true);
      
      vm.prank(ADDRESS2);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS2),' is missing role ', DEFAULT_ROLE_HASH));
      vm.expectRevert(bytes(message));
      CMTAT_CONTRACT.revokeRole(PAUSER_ROLE, ADDRESS1);
      
      bool res3 = CMTAT_CONTRACT.hasRole(PAUSER_ROLE, ADDRESS1);
      assertEq(res3, true);
    }
}
