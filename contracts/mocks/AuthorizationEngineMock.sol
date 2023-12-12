//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../interfaces/engine/IAuthorizationEngine.sol";

/*
@title a mock for testing, not suitable for production
*/
contract AuthorizationEngineMock is IAuthorizationEngine {
    address nextAdmin;

    constructor() {
        
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function authorizeAdminChange(address newAdmin) external {
        nextAdmin = newAdmin;
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function operateOnAuthorization(
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
}
