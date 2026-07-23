//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "./interfaces/IRule.sol";
import {CodeList} from "./CodeList.sol";

/*
* @title a mock rule for spender authorization, not suitable for production
*/
contract RuleSpenderAuthorized is IRule, CodeList {
    uint8 constant SPENDER_NOT_AUTHORIZED = 21;
    string constant TEXT_SPENDER_NOT_AUTHORIZED = "Spender not authorized";

    address immutable authorizedSpender;

    constructor(address spender) {
        authorizedSpender = spender;
    }

    function canTransfer(
        address /*_from*/,
        address /*_to*/,
        uint256 /*_amount*/
    ) public pure override returns (bool isValid) {
        return true;
    }

    function detectTransferRestriction(
        address /*_from*/,
        address /*_to*/,
        uint256 /*_amount*/
    ) public pure override returns (uint8) {
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function detectTransferRestrictionFrom(
        address spender,
        address /*_from*/,
        address /*_to*/,
        uint256 /*_amount*/
    ) public view override returns (uint8) {
        if (spender == address(0) || spender == authorizedSpender) {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
        return SPENDER_NOT_AUTHORIZED;
    }

    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) public pure override returns (bool) {
        return _restrictionCode == SPENDER_NOT_AUTHORIZED;
    }

    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external pure override returns (string memory) {
        return
            _restrictionCode == SPENDER_NOT_AUTHORIZED
                ? TEXT_SPENDER_NOT_AUTHORIZED
                : TEXT_CODE_NOT_FOUND;
    }
}
