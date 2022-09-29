pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "../src/CMTAT.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract BaseModuleTest is Test, BaseModule {
   string constant MINTER_ROLE_HASH  = 
    '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6';
    string constant DEFAULT_ADMIN_ROLE_HASH  = 
    '0x0000000000000000000000000000000000000000000000000000000000000000';
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

    // has the defined name
    function testDefinedName () public {
      string memory res1 = CMTAT_CONTRACT.name();
      assertEq(res1, 'CMTA Token');
    }
    
    // has the defined symbol
    function testDefinedSymbol () public {
      string memory res1 = CMTAT_CONTRACT.symbol();
      assertEq(res1, 'CMTAT');
    }
    
    // is not divisible
    // TODO : Clarify the test
    function testIsNotDivisible () public {
     uint8 res1 = CMTAT_CONTRACT.decimals();
     assertEq(res1, 0);
    }
    
    // is has a token ID
    function testHasTokenId() public {
      string memory res1 = CMTAT_CONTRACT.tokenId();
      assertEq(res1, 'CMTAT_ISIN');
    }
    
    // is has terms
    function testHasTerms () public {
       string memory res1 = CMTAT_CONTRACT.terms();
       assertEq(res1, 'https://cmta.ch');
    }
    
    // allows the admin to modify the token ID
    function testAllowModifyTokenidByAdmin() public {
      string memory res1 = CMTAT_CONTRACT.tokenId();
      assertEq(res1, 'CMTAT_ISIN');
      
      vm.prank(OWNER);
      CMTAT_CONTRACT.setTokenId('CMTAT_TOKENID');
      string memory res2 = CMTAT_CONTRACT.tokenId();
      assertEq(res2, 'CMTAT_TOKENID');
    }
    
    // reverts when trying to modify the token ID from non-admin
    function testCannotModifyTokenIdByNonAdmin () public {
      string memory res1 = CMTAT_CONTRACT.tokenId();
      assertEq(res1, 'CMTAT_ISIN');
      
      vm.prank(ADDRESS1);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS1),' is missing role ', DEFAULT_ADMIN_ROLE_HASH));
      vm.expectRevert(bytes(message));
      
      CMTAT_CONTRACT.setTokenId('CMTAT_TOKENID');
     
      string memory res2 = CMTAT_CONTRACT.tokenId();
       assertEq(res2, 'CMTAT_ISIN');
    }
    
    // allows the admin to modify the terms
    // TODO : test if the admin can update the term.
    function testAdminCanUpdateTerms() public {
      string memory res1 = CMTAT_CONTRACT.terms();
      assertEq(res1, 'https://cmta.ch');

      vm.prank(OWNER);
      CMTAT_CONTRACT.setTerms('https://cmta.ch/terms');
      string memory res2 = CMTAT_CONTRACT.terms();
      assertEq(res2, 'https://cmta.ch/terms');
    }
    
    // reverts when trying to modify the terms from non-admin
    function testCannotModifyTermsByNonAdmin () public {
      string memory res1 = CMTAT_CONTRACT.terms();
      assertEq(res1, 'https://cmta.ch');

      vm.prank(ADDRESS1);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS1),' is missing role ', DEFAULT_ADMIN_ROLE_HASH));
      vm.expectRevert(bytes(message));
      CMTAT_CONTRACT.setTerms('https://cmta.ch/terms');
      string memory res2 = CMTAT_CONTRACT.terms();
      assertEq(res2, 'https://cmta.ch');
    }
    
    // allows the admin to kill the contract
    function testAdminCanKillContract () public {
      vm.prank(OWNER);
      CMTAT_CONTRACT.kill();
      // TODO : Check if the contract is really kill
    }
    
    // reverts when trying to kill the contract from non-admin
    function testCannotKillContractByNonAdmin () public {
      // TODO: check the value of the terms at the beginning of test.
      vm.prank(ADDRESS1);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS1),' is missing role ', DEFAULT_ADMIN_ROLE_HASH));
      vm.expectRevert(bytes(message));
      
      CMTAT_CONTRACT.kill();
      
      string memory res1 = CMTAT_CONTRACT.terms();
      assertEq(res1, 'https://cmta.ch');
    }
  }

 contract AllowanceTest is  Test, BaseModule{
    //BaseModuleTest baseModuleTestContract = new BaseModuleTest(); 
   string constant MINTER_ROLE_HASH  = 
    '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6';
    string constant DEFAULT_ADMIN_ROLE_HASH  = 
    '0x0000000000000000000000000000000000000000000000000000000000000000';
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
    
    // 'allows ADDRESS1 to define a spending allowance for ADDRESS3'
    function testCanAllowSpengAllowanceByAddr1ForAddr3 () public {
      uint256 res1 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res1, 0);

      vm.prank(ADDRESS1);
      vm.expectEmit(true, true, false, true);
      // emits an Approval event
      emit Approval(ADDRESS1, ADDRESS3, 20 );

      CMTAT_CONTRACT.approve(ADDRESS3, 20);

      uint256 res2 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res2, 20);
    }

    // allows ADDRESS1 to increase the allowance for ADDRESS3
    function testIncreaseAllowance () public {
      uint256 res1 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res1, 0);
      
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS3, 20);
      uint256 res2 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res2, 20);

      vm.expectEmit(true, true, false, true);
      emit Approval(ADDRESS1, ADDRESS3, 30 );
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.increaseAllowance(ADDRESS3, 10);
      
      uint256 res3 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res3, 30);       
    }

    // 'allows ADDRESS1 to decrease the allowance for ADDRESS3'
    function testDecreaseAllowance () public {
      uint256 res1 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res1, 0);

      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS3, 20);
      uint256 res2 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res2, 20);
      
      vm.prank(ADDRESS1);
      vm.expectEmit(true, true, false, true);
      emit Approval(ADDRESS1, ADDRESS3, 10);
      
      CMTAT_CONTRACT.decreaseAllowance(ADDRESS3, 10);
      
      uint256 res3 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res3, 10);  
    }

    // 'allows ADDRESS1 to redefine a spending allowance for ADDRESS3'
    function testRedefineSpendingAllowance () public {
      uint256 res1 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res1, 0);

      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS3, 20);
      uint256 res2 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res2, 20);

      vm.prank(ADDRESS1);
      vm.expectEmit(true, true, false, true);
      // emits an Approval event
      emit Approval(ADDRESS1, ADDRESS3, 50 );

      CMTAT_CONTRACT.approve(ADDRESS3, 50);

      uint256 res3 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res3, 50);
    }

    // 'allows ADDRESS1 to define a spending allowance for ADDRESS3 taking current allowance in account'
   function testDefineSpendingAllowance() public {
      uint256 res1 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res1, 0);
      
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS3, 20);
      uint256 res2 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res2, 20);   
      
      // TODO What is this notation ?
      // TODO : Check method type
      vm.prank(ADDRESS1);
      vm.expectEmit(true, true, false, true);
      // emits an Approval event
      emit Approval(ADDRESS1, ADDRESS3, 30);
      CMTAT_CONTRACT.approve(ADDRESS3, 30, 20);

      uint256 res3 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res3, 30);   
    }
  
    // 'reverts if trying to define a spending allowance for ADDRESS3 with wrong current allowance'
    function testCannotDefineSpendingWrongAllowance () public {
      uint256 res1 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res1, 0);
      
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS3, 20);
      
      uint256 res2 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res2, 20);
      
      // TODO : Check method type
      // TODO : Check the reason of revert
      vm.prank(ADDRESS1);
      vm.expectRevert(bytes('CMTAT: current allowance is not right'));
      CMTAT_CONTRACT.approve(ADDRESS3, 30, 10);
     
      // TODO : Check method type 
      uint256 res3 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res3, 20);
    }
  }

   contract TransferTest is Test, BaseModule{
     string constant MINTER_ROLE_HASH  = 
    '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6';
    string constant DEFAULT_ADMIN_ROLE_HASH  = 
    '0x0000000000000000000000000000000000000000000000000000000000000000';
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
        
        // Personal config
        vm.prank(OWNER);
        CMTAT_CONTRACT.mint(ADDRESS1, 31);

        vm.prank(OWNER);
        CMTAT_CONTRACT.mint(ADDRESS2, 32);

        vm.prank(OWNER);
        CMTAT_CONTRACT.mint(ADDRESS3, 33);
    }

    // allows ADDRESS1 to transfer tokens to ADDRESS2
    function testAllowTransferFromOneAccountToAnother () public {
      vm.prank(ADDRESS1);
      vm.expectEmit(true, true, false, true);
      // emits a Transfer event
      emit Transfer(ADDRESS1, ADDRESS2, 11);

      CMTAT_CONTRACT.transfer(ADDRESS2, 11); 

      uint256 res1 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
      assertEq(res1, 20);

      uint256 res2 =  CMTAT_CONTRACT.balanceOf(ADDRESS2);
      assertEq(res2, 43);
      
      uint256 res3 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
      assertEq(res3, 33);

      uint256 res4 = CMTAT_CONTRACT.totalSupply();
      assertEq(res4, 96);      
    }

    // reverts if ADDRESS1 transfers more tokens than he owns to ADDRESS2
    function testFailTransferMoreTokensThanOwn () public {
      // TODO : Check the reason of revert
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.transfer(ADDRESS2, 50);  
      // TODO : Check the allowance      
    }

    // allows ADDRESS3 to transfer tokens from ADDRESS1 to ADDRESS2
    // with the right allowance
    function testAllowTransferByAnotherAccount () public {
      // Define allowance
      vm.prank(ADDRESS1);
      // TODO : Check the allowance
      CMTAT_CONTRACT.approve(ADDRESS3, 20);

      // Transfer
      vm.prank(ADDRESS3);
      
      // emits a Transfer event
      vm.expectEmit(true, true, false, true);
      emit Transfer(ADDRESS1, ADDRESS2, 11);
      vm.expectEmit(true, true, false, true);
      // emits a Spend event
      emit Spend(ADDRESS1, ADDRESS3, 11);
      CMTAT_CONTRACT.transferFrom(ADDRESS1, ADDRESS2, 11); 
      uint256 res1 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
      assertEq(res1, 20);
      
      uint256 res2 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
      assertEq(res2, 43);
      
      uint256 res3 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
      assertEq(res3, 33);
      
      uint256 res4 = CMTAT_CONTRACT.totalSupply();         
      assertEq(res4, 96);
    }

    // reverts if ADDRESS3 transfers more tokens than the
    // allowance from ADDRESS1 to ADDRESS2
    function testFailMoreTokensThanAllowance () public {
      // Define allowance
      uint256 res1 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res1, 0);

      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS3, 20);
      
      uint256 res2 = CMTAT_CONTRACT.allowance(ADDRESS1, ADDRESS3);
      assertEq(res2, 20);

      // Transfer
      // TODO : Check the reason of revert
      vm.prank(ADDRESS3);
      CMTAT_CONTRACT.transferFrom(ADDRESS1, ADDRESS2, 31);        
    }

    // reverts if ADDRESS3 transfers more tokens 
    // than ADDRESS1 owns from ADDRESS1 to ADDRESS2
    function testFailTransferMoreTokenThanOwn () public {
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.approve(ADDRESS3, 1000);
      // TODO : Check the reason of revert
      vm.prank(ADDRESS3);
      CMTAT_CONTRACT.transferFrom(ADDRESS1, ADDRESS2, 50);        
    }
  }
