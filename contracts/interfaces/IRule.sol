//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./IRuleCommon.sol";


interface IRule is IRuleCommon {
     function canReturnTransferRestrictionCode(uint8 _restrictionCode)
        external
        view
        returns (bool);
}
