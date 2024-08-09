//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../../libraries/Errors.sol";
import "../../interfaces/engine/IAuthorizationEngine.sol";

abstract contract AuthorizationModule is AccessControlUpgradeable {
    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event AuthorizationEngine(IAuthorizationEngine indexed newAuthorizationEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.AuthorizationModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AuthorizationModuleStorageLocation = 0x59b7f077fa4ad020f9053fd2197fef0113b19f0b11dcfe516e88cbc0e9226d00;
    /* ==== ERC-7201 State Variables === */
    struct AuthorizationModuleStorage {
        IAuthorizationEngine _authorizationEngine;
    }
    /* ============  Initializer Function ============ */
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
        if (address(authorizationEngine_) != address (0)) {
            AuthorizationModuleStorage storage $ = _getAuthorizationModuleStorage();
            $._authorizationEngine = authorizationEngine_;
            emit AuthorizationEngine(authorizationEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function authorizationEngine() public view virtual returns (IAuthorizationEngine) {
        AuthorizationModuleStorage storage $ = _getAuthorizationModuleStorage();
        return $._authorizationEngine;
    }


    /*
    * @notice set an authorizationEngine if not already set
    * @dev once an AuthorizationEngine is set, it is not possible to unset it
    */
    function setAuthorizationEngine(
        IAuthorizationEngine authorizationEngine_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        AuthorizationModuleStorage storage $ = _getAuthorizationModuleStorage();
        if (address($._authorizationEngine) != address (0)){
            revert Errors.CMTAT_AuthorizationModule_AuthorizationEngineAlreadySet();
        }
        $._authorizationEngine = authorizationEngine_;
        emit AuthorizationEngine(authorizationEngine_);
    }

    function grantRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        AuthorizationModuleStorage storage $ = _getAuthorizationModuleStorage();
        if (address($._authorizationEngine) != address (0)) {
            bool result = $._authorizationEngine.operateOnGrantRole(role, account);
            if(!result) {
                // Operation rejected by the authorizationEngine
               revert Errors.CMTAT_AuthorizationModule_InvalidAuthorization();
            }
        }
        return AccessControlUpgradeable.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        AuthorizationModuleStorage storage $ = _getAuthorizationModuleStorage();
        if (address($._authorizationEngine) != address (0)) {
            bool result = $._authorizationEngine.operateOnRevokeRole(role, account);
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


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /* ============ ERC-7201 ============ */
    function _getAuthorizationModuleStorage() private pure returns (AuthorizationModuleStorage storage $) {
        assembly {
            $.slot := AuthorizationModuleStorageLocation
        }
    }
}
