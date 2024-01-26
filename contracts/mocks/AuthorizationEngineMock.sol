//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../interfaces/engine/IAuthorizationEngine.sol";

/*
@title a mock for testing, not suitable for production
*/
contract AuthorizationEngineMock is IAuthorizationEngine {
    address nextAdmin;
    bool revokeAdminRoleAuthorized;
    constructor() {
        revokeAdminRoleAuthorized = true;
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function authorizeAdminChange(address newAdmin) external {
        nextAdmin = newAdmin;
    }

    function setRevokeAdminRoleAuthorized(bool
    newValue) external {
        revokeAdminRoleAuthorized = newValue;
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function operateOnGrantRole(
        bytes32 role, address account
    ) external returns (bool isValid){
        if(role == 0x0 && account == nextAdmin && account != address(0x0)){
            // Reset to 0
            nextAdmin = address(0x0);
            return true;
        }else{
            return false;
        }
    }

        /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function operateOnRevokeRole(
        bytes32 role, address /*account*/
    ) external view returns (bool isValid){
        if(role == 0x0){
            return revokeAdminRoleAuthorized;
        } else{
            // the tests will fail if this branch is taken
            return !revokeAdminRoleAuthorized;
        }
    }
}
