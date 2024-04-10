//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

import "./draft-IERC1404.sol";
import "./draft-IERC1404EnumCode.sol";

interface IERC1404Wrapper is IERC1404, IERC1404EnumCode  {

    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool isValid);
}
