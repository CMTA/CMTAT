//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev CMTAT custom errors
*/
library Errors {
    // CMTAT Base
    error CMTAT_InvalidTransfer(address from, address to, uint256 amount);
}   
