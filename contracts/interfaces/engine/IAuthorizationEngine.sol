// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev minimum interface to define an AuthorizationEngine
*/
interface IAuthorizationEngine {
    /**
     * @dev Returns true if the operation is authorized, and false otherwise.
     */
    function operateOnGrantRole(
        bytes32 role, address account
    ) external returns (bool isValid);

    /**
     * @dev Returns true if the operation is authorized, and false otherwise.
     */
    function operateOnRevokeRole(
        bytes32 role, address account
    ) external returns (bool isValid);
   
}
