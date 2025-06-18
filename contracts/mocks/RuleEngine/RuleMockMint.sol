//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "./interfaces/IRule.sol";
import {CodeList} from "./CodeList.sol";


/*
* @title a mock for testing, not suitable for production
*/
contract RuleMockMint is IRule, CodeList {
    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public pure override returns (bool isValid) {
        return detectTransferRestriction(_from, _to, _amount) == 0;
    }

    /**
    * @dev 20 the limit of the maximum amount
    */
    function detectTransferRestriction(
        address _from,
        address /* _to */,
        uint256 _amount
    ) public pure override returns (uint8) {
        if(_from == address(0)){
            return  _amount < 20
                ? uint8(REJECTED_CODE_BASE.TRANSFER_OK)
                : MINT_TOO_HIGH;
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
           
    }

    function detectTransferRestrictionFrom(
        address /* spender*/,
        address _from,
        address  _to,
        uint256 _amount
    ) public pure override returns (uint8) {
        return detectTransferRestriction(_from,_to, _amount);
           
    }

    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) public pure override returns (bool) {
        return _restrictionCode == MINT_TOO_HIGH;
    }

    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external pure override returns (string memory) {
        return
            _restrictionCode == MINT_TOO_HIGH
                ? TEXT_MINT_TOO_HIGH
                : TEXT_CODE_NOT_FOUND;
    }
}
