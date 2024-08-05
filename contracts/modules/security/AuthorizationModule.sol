//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../libraries/Errors.sol";
import "../../interfaces/engine/IAuthorizationEngine.sol";

abstract contract AuthorizationModule is AccessControlUpgradeable {
    IAuthorizationEngine private authorizationEngine;
    /**
     * @dev Emitted when a rule engine is set.
     */
    event AuthorizationEngine(IAuthorizationEngine indexed newAuthorizationEngine);
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __AuthorizationModule_init_unchained(address admin, IAuthorizationEngine authorizationEngine_)
    internal onlyInitializing {
        if(admin == address(0)){
            revert Errors.CMTAT_AuthorizationModule_AddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        if (address(authorizationEngine) != address (0)) {
            authorizationEngine = authorizationEngine_;
            emit AuthorizationEngine(authorizationEngine_);
        }
    }

    /*
    * @notice set an authorizationEngine if not already set
    * @dev once an AuthorizationEngine is set, it is not possible to unset it
    */
    function setAuthorizationEngine(
        IAuthorizationEngine authorizationEngine_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(authorizationEngine) != address (0)){
            revert Errors.CMTAT_AuthorizationModule_AuthorizationEngineAlreadySet();
        }
        authorizationEngine = authorizationEngine_;
        emit AuthorizationEngine(authorizationEngine_);
    }

    function grantRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        if (address(authorizationEngine) != address (0)) {
            bool result = authorizationEngine.operateOnGrantRole(role, account);
            if(!result) {
                // Operation rejected by the authorizationEngine
               revert Errors.CMTAT_AuthorizationModule_InvalidAuthorization();
            }
        }
        return AccessControlUpgradeable.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        if (address(authorizationEngine) != address (0)) {
            bool result = authorizationEngine.operateOnRevokeRole(role, account);
            if(!result) {
                // Operation rejected by the authorizationEngine
               revert Errors.CMTAT_AuthorizationModule_InvalidAuthorization();
            }
        }
        return AccessControlUpgradeable.revokeRole(role, account);
    }

    /** 
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable) returns (bool) {
        // The Default Admin has all roles
        if (AccessControlUpgradeable.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        }
        return AccessControlUpgradeable.hasRole(role, account);
    }

    uint256[50] private __gap;
}
