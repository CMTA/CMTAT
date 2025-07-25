// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract CodeList {
    // Used by RuleMock.sol
    uint8 constant AMOUNT_TOO_HIGH = 13;
    uint8 constant MINT_TOO_HIGH = 20;
    string constant TEXT_AMOUNT_TOO_HIGH = "Amount too high";
    string constant TEXT_MINT_TOO_HIGH = "Mint amount too high";
    string constant TEXT_CODE_NOT_FOUND = "Code not found";
}
