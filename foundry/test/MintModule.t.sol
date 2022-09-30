pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "./HelperContract.sol";
contract MintModuleTest is Test, HelperContract, MintModule, ERC20Upgradeable {
    function setUp() public {
     vm.prank(OWNER);
     CMTAT_CONTRACT = new CMTAT();
     CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    }

    //can be minted as the owner
    function testCanBeMintedByOwner() public{
      // Check first balance
      uint256 res1 = CMTAT_CONTRACT.balanceOf(OWNER);
      assertEq(res1, 0);

      // Issue 20 and check balances and total supply
      //log1
      vm.prank(OWNER);
      vm.expectEmit(true, true, false, true);
      emit Transfer(ZERO_ADDRESS, ADDRESS1, 20 );
      vm.expectEmit(true, false, false, true);
      emit Mint(ADDRESS1, 20 );
      CMTAT_CONTRACT.mint(ADDRESS1, 20);
      
      uint256 res2 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
      assertEq(res2, 20);
      
      uint256 res3 = CMTAT_CONTRACT.totalSupply();
      assertEq(res3, 20);

      // Issue 50 and check intermediate balances and total supply
      //log2
      vm.prank(OWNER);
      vm.expectEmit(true, true, false, true);
      emit Transfer(ZERO_ADDRESS, ADDRESS2, 50 );
      vm.expectEmit(true, false, false, true);
      emit Mint(ADDRESS2, 50 );
      
      CMTAT_CONTRACT.mint(ADDRESS2, 50);
      uint256 res4 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
      assertEq(res4, 50);

      uint256 res5 = CMTAT_CONTRACT.totalSupply();
      assertEq(res5, 70);
    }

    // can be minted by anyone with minter role
    function testCanBeMintedByMinterRole () public {
      vm.prank(OWNER);
      CMTAT_CONTRACT.grantRole(MINTER_ROLE, ADDRESS1);
      // Check first balance
      uint256 res1 = CMTAT_CONTRACT.balanceOf(OWNER);
      assertEq(res1, 0);

      // Issue 20 and check balances and total supply
      vm.prank(ADDRESS1);
      //log1
      vm.expectEmit(true, true, false, true);
      emit Transfer(ZERO_ADDRESS, ADDRESS1, 20 );
      emit Mint(ADDRESS1, 20 );
      CMTAT_CONTRACT.mint(ADDRESS1, 20);

      uint256 res2 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
      assertEq(res2, 20);


      uint256 res3 = CMTAT_CONTRACT.totalSupply();
      assertEq(res3, 20);
    }

    // reverts when issuing from non-owner
    function testCannotIssuingFromNonOwner() public{
        vm.prank(ADDRESS1);
        string memory message = string(abi.encodePacked('AccessControl: account ', 
        vm.toString(ADDRESS1),' is missing role ', MINTER_ROLE_HASH));
        vm.expectRevert(bytes(message));
        CMTAT_CONTRACT.mint(ADDRESS1, 20);
    }


}