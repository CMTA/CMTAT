//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404Extend} from "../../../interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead} from "../../../interfaces/tokenization/IERC3643Partial.sol";
interface IRule is IERC1404Extend, IERC3643ComplianceRead {
    /**
     * @dev Returns true if the restriction code exists, and false otherwise.
     */
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external view returns (bool);
}
