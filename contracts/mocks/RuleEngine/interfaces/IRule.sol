//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol";

interface IRule is IERC1404Wrapper {
    /**
     * @dev Returns true if the restriction code exists, and false otherwise.
     */
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external view returns (bool);
}
