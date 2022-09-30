pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "./HelperContract.sol";

contract PauseModuleTest is Test, HelperContract, PauseModule {

    function setUp() public {
     vm.prank(OWNER);
     CMTAT_CONTRACT = new CMTAT();
     CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    }

    // can be paused by the owner
    function testPausedByOwner() public {
        vm.prank(OWNER);
        vm.expectEmit(false, false, false, true);
        emit Paused(OWNER);
        CMTAT_CONTRACT.pause(); 
    }

    // can be paused by the anyone having pauser role
    function testPausedByPauserRole() public {
        vm.prank(OWNER);
        // TODO : Check event
        CMTAT_CONTRACT.grantRole(PAUSER_ROLE, ADDRESS1);
        
        vm.prank(ADDRESS1);
        // TODO : Check event
        CMTAT_CONTRACT.pause();
    }

    // reverts when calling from non-owner
    function testCannotWhenCallingFromNonOwner() public {
    //Strings.toHexString (abi.encodePacked(PAUSER_ROLE)
    string memory message = string(abi.encodePacked('AccessControl: account ', 
     Strings.toHexString(ADDRESS1),' is missing role ', PAUSER_ROLE_HASH));
        vm.expectRevert(bytes(message));
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.pause();
    }

    // can be unpaused by the owner
    function testUnpausedByOwner() public{
        vm.prank(OWNER);
        CMTAT_CONTRACT.pause();
        
        vm.prank(OWNER);
        vm.expectEmit(false, false, false, true);
        emit Unpaused(OWNER);
        CMTAT_CONTRACT.unpause();
    }

    // can be paused by the anyone having pauser role
    function testcanBePausedByPauserRole() public{
        // TODO : Replace owner by adress1 to call the function pause
        vm.prank(OWNER);
        CMTAT_CONTRACT.pause();
        
        vm.prank(OWNER);
        CMTAT_CONTRACT.grantRole(PAUSER_ROLE, ADDRESS1);
        
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.unpause();
    }

    // reverts when calling from non-owner
    function testCannotPauseNonOwner() public{
        // TODO : Replace owner by adress1 to call the function pause
        vm.prank(OWNER);
        CMTAT_CONTRACT.pause();
        vm.prank(ADDRESS1);
        string memory message = string(abi.encodePacked('AccessControl: account ', 
        Strings.toHexString(ADDRESS1),' is missing role ', PAUSER_ROLE_HASH));
        vm.expectRevert(bytes(message));
        CMTAT_CONTRACT.unpause();
    }

    // reverts if address1 transfers tokens to address2 when paused
    function testCannotTransferTokenWhenPaused_A() public{
         vm.prank(OWNER);
         CMTAT_CONTRACT.pause();
         
        //detectTransferRestriction
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(ADDRESS1, ADDRESS2, 10);
        assertEq(res1, 1);

        string memory res2 = CMTAT_CONTRACT.messageForTransferRestriction(1);
        assertEq(res2, "All transfers paused");

        vm.prank(ADDRESS1);
        vm.expectRevert(bytes('CMTAT: token transfer while paused'));
        CMTAT_CONTRACT.transfer(ADDRESS2, 10);
    }


    // reverts if address3 transfers tokens from address1 to address2 when paused
    function testCannotTransferTokenWhenPaused_B() public {
        vm.prank(ADDRESS1);
        // Define allowance
        CMTAT_CONTRACT.approve(ADDRESS3, 20);

        vm.prank(OWNER);
        CMTAT_CONTRACT.pause();

        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(ADDRESS1, ADDRESS2, 10);
        assertEq(res1, 1);

        string memory res2 = CMTAT_CONTRACT.messageForTransferRestriction(1);
        assertEq(res2, "All transfers paused");
       
        vm.prank(ADDRESS3);
        vm.expectRevert(bytes('CMTAT: token transfer while paused'));
        CMTAT_CONTRACT.transferFrom(ADDRESS1, ADDRESS2, 10);   
    }
}