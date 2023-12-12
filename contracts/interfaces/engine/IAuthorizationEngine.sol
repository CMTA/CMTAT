// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

interface IAuthorizationEngine {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function operateOnAuthorization(
        bytes32 role, address account
    ) external returns (bool isValid);
   
}
