// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

abstract contract CodeList {
    
    uint8 constant NO_ERROR = 0;
    // Used by RuleMock.sol
    uint8 constant AMOUNT_TOO_HIGH = 10;
    string constant TEXT_AMOUNT_TOO_HIGH = "Amount too high";
    string constant TEXT_CODE_NOT_FOUND = "Code not found";
}