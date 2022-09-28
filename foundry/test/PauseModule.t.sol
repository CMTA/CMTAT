pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "../src/CMTAT.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
  //address constant CHEATCODE_ADDRESS = 0x7cFA93148B0B13d88c1DcE8880bd4e175;
  /*

  */
contract PauseModuleTest is Test, PauseModule {
    string constant PAUSER_ROLE_HASH  = 
    '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a';
    //Vm vm = Vm(CHEATCODE_ADDRESS);
    CMTAT cmtatContract;
    address constant ADDRESS_NULL = address(0);
    address constant OWNER = address(1);
    address constant ADDRESS1 = address(2);
    address constant ADDRESS2 = address(3);
    address constant ADDRESS3 = address(4);

    function setUp() public {
     vm.prank(OWNER);
     cmtatContract = new CMTAT();
     cmtatContract.initialize(OWNER, ADDRESS_NULL, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    }

    // can be paused by the owner
    function testPausedByOwner() public {
        vm.prank(OWNER);
        vm.expectEmit(false, false, false, true);
        emit Paused(OWNER);
        cmtatContract.pause(); 
    }

    // can be paused by the anyone having pauser role
    function testPausedByPauserRole() public {
        vm.prank(OWNER);
        // TODO : Check event
        cmtatContract.grantRole(PAUSER_ROLE, ADDRESS1);
        
        vm.prank(ADDRESS1);
        // TODO : Check event
        cmtatContract.pause();
    }

    // reverts when calling from non-owner
    function testCannotWhenCallingFromNonOwner() public {
    //Strings.toHexString (abi.encodePacked(PAUSER_ROLE)
    string memory message = string(abi.encodePacked('AccessControl: account ', 
     Strings.toHexString(ADDRESS1),' is missing role ', PAUSER_ROLE_HASH));
        vm.expectRevert(bytes(message));
        vm.prank(ADDRESS1);
        cmtatContract.pause();
    }

    // can be unpaused by the owner
    function testUnpausedByOwner() public{
        vm.prank(OWNER);
        cmtatContract.pause();
        
        vm.prank(OWNER);
        vm.expectEmit(false, false, false, true);
        emit Unpaused(OWNER);
        cmtatContract.unpause();
    }

    // can be paused by the anyone having pauser role
    function testcanBePausedByPauserRole() public{
        // TODO : Replace owner by adress1 to call the function pause
        vm.prank(OWNER);
        cmtatContract.pause();
        
        vm.prank(OWNER);
        cmtatContract.grantRole(PAUSER_ROLE, ADDRESS1);
        
        vm.prank(ADDRESS1);
        cmtatContract.unpause();
    }

    // reverts when calling from non-owner
    function testCannotPauseNonOwner() public{
        // TODO : Replace owner by adress1 to call the function pause
        vm.prank(OWNER);
        cmtatContract.pause();
        vm.prank(ADDRESS1);
        string memory message = string(abi.encodePacked('AccessControl: account ', 
        Strings.toHexString(ADDRESS1),' is missing role ', PAUSER_ROLE_HASH));
        vm.expectRevert(bytes(message));
        cmtatContract.unpause();
    }

    // reverts if address1 transfers tokens to address2 when paused
    function testCannotTransferTokenWhenPaused_A() public{
         vm.prank(OWNER);
         cmtatContract.pause();
         
        //detectTransferRestriction
        uint8 res1 = cmtatContract.detectTransferRestriction(ADDRESS1, ADDRESS2, 10);
        assertEq(res1, 1);

        string memory res2 = cmtatContract.messageForTransferRestriction(1);
        assertEq(res2, "All transfers paused");

        vm.prank(ADDRESS1);
        vm.expectRevert(bytes('CMTAT: token transfer while paused'));
        cmtatContract.transfer(ADDRESS2, 10);
    }


    // reverts if address3 transfers tokens from address1 to address2 when paused
    function testCannotTransferTokenWhenPaused_B() public {
        vm.prank(ADDRESS1);
        // Define allowance
        cmtatContract.approve(ADDRESS3, 20);

        vm.prank(OWNER);
        cmtatContract.pause();

        uint8 res1 = cmtatContract.detectTransferRestriction(ADDRESS1, ADDRESS2, 10);
        assertEq(res1, 1);

        string memory res2 = cmtatContract.messageForTransferRestriction(1);
        assertEq(res2, "All transfers paused");
       
        vm.prank(ADDRESS3);
        vm.expectRevert(bytes('CMTAT: token transfer while paused'));
        cmtatContract.transferFrom(ADDRESS1, ADDRESS2, 10);   
    }
}