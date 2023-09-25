// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract CodeList {
    // Used by RuleMock.sol
    uint8 constant AMOUNT_TOO_HIGH = 10;
    string constant TEXT_AMOUNT_TOO_HIGH = "Amount too high";
    string constant TEXT_CODE_NOT_FOUND = "Code not found";
}
