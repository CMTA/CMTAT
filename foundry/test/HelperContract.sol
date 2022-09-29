pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/CMTAT.sol";

abstract contract HelperContract {
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
    string constant SNAPSHOOTER_ROLE = '0x809a0fc49fc0600540f1d39e23454e1f6f215bc7505fa22b17c154616570ddef';
    constructor() {}
}