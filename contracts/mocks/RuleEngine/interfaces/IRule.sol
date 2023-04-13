//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

import "../../../interfaces/IEIP1404/IEIP1404Wrapper.sol";

interface IRule is IEIP1404Wrapper {
    /**
     * @dev Returns true if the restriction code exists, and false otherwise.
     */
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external view returns (bool);
}
