pragma solidity ^0.8.17;
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "./HelperContract.sol";

contract BurnModuleTest is Test, HelperContract, BurnModule, ERC20Upgradeable {
    uint256 resUint256;
    function setUp() public {
        vm.prank(OWNER);
        CMTAT_CONTRACT = new CMTAT();
        CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
        vm.prank(OWNER);
        CMTAT_CONTRACT.mint(ADDRESS1, 50);
        resUint256 = CMTAT_CONTRACT.totalSupply();
        assertEq(resUint256, 50);
    }


    // can be burnt as the OWNER with allowance
    function canBeBurntByOwnerWithAllowance () public {
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.approve(OWNER, 50);
        // Burn 20 and check balances and total supply
        vm.prank(OWNER);
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(ADDRESS1, ZERO_ADDRESS,  20 );

        vm.expectEmit(true, false, false, true);
        emit Burn(ADDRESS1, 20 );
        
        CMTAT_CONTRACT.burnFrom(ADDRESS1, 20);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, 30);
        resUint256 = CMTAT_CONTRACT.totalSupply();
        assertEq(resUint256, 30);
        // Burn 30 and check balances and total supply
        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(ADDRESS1, ZERO_ADDRESS, 30 );
         vm.expectEmit(true, false, false, true);
        emit Burn(ADDRESS1, 30 );
        CMTAT_CONTRACT.burnFrom(ADDRESS1, 30);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, 0);
        resUint256 = CMTAT_CONTRACT.totalSupply();
        assertEq(resUint256, 0);
    }

    // can be burnt as anyone with burner role and allowance
    function testCanBurntByBurnerRole () public {
      vm.prank(OWNER);
      CMTAT_CONTRACT.grantRole(BURNER_ROLE, ADDRESS2);
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS2, 50);
      vm.prank(ADDRESS2);
      CMTAT_CONTRACT.burnFrom(ADDRESS1, 20);
      resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
      assertEq(resUint256, 30);
      resUint256 = CMTAT_CONTRACT.totalSupply();
      assertEq(resUint256, 30);
    }

    // reverts when burning without allowance
    function testCannotBurningWithoutAllowance () public {
      vm.prank(OWNER);
      vm.expectRevert(bytes('CMTAT: burn amount exceeds allowance'));
      CMTAT_CONTRACT.burnFrom(ADDRESS1, 20);
    }

    // reverts when burning without burner role
    function testCannotBurnWithoutBurnerRole () public {
      vm.prank(ADDRESS2);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS2),' is missing role ', BURNER_ROLE_HASH));
      vm.expectRevert(bytes(message));
      CMTAT_CONTRACT.burnFrom(ADDRESS1, 20);
    }
}
