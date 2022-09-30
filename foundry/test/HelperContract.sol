pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/CMTAT.sol";
abstract contract HelperContract {
    CMTAT CMTAT_CONTRACT;
    address constant ZERO_ADDRESS = address(0);
    address constant OWNER = address(1);
    address constant ADDRESS1 = address(2);
    address constant ADDRESS2 = address(3);
    address constant ADDRESS3 = address(4);
     string constant DEFAULT_ROLE_HASH  = 
    '0x0000000000000000000000000000000000000000000000000000000000000000';
    string constant SNAPSHOOTER_ROLE_HASH = '0x809a0fc49fc0600540f1d39e23454e1f6f215bc7505fa22b17c154616570ddef';
    string constant BURNER_ROLE_HASH = '0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848' ;
    string constant MINTER_ROLE_HASH = '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6'; //keccak256("MINTER_ROLE");
//keccak256("BURNER_ROLE");
    string constant ENFORCER_ROLE_HASH = '0x973ef39d76cc2c6090feab1c030bec6ab5db557f64df047a4c4f9b5953cf1df3'; //keccak256("ENFORCER_ROLE");
    string constant PAUSER_ROLE_HASH = '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a'; //keccak256("PAUSER_ROLE");
    string constant DEFAULT_ADMIN_ROLE_HASH = '0x0000000000000000000000000000000000000000000000000000000000000000';
    //string constant ZERO_ADDRESS_STRING = '0x0000000000000000000000000000000000000000';
    
    constructor() {}
}