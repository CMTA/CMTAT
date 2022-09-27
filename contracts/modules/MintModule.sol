//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

abstract contract MintModule {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Mint (address indexed beneficiary, uint amount);
}
