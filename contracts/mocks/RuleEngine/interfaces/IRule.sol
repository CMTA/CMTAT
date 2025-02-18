//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404} from "../../../interfaces/draft-IERC1404.sol";
import {IERC3643Compliance} from "../../../interfaces/IERC3643Partial.sol";
interface IRule is IERC1404, IERC3643Compliance {
    /**
     * @dev Returns true if the restriction code exists, and false otherwise.
     */
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external view returns (bool);
}
